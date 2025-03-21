# frozen_string_literal: true

module Stats
  class SystemSetStatsService < ApplicationService

    def call(systems, stats_set_name)
      begin
        success SystemSetStats.new(systems, stats_set_name)
      rescue Exception => e
        failure e
      end
    end
  end

  Datum = Struct.new(:description, :value)

  class SystemSetStats
    attr_reader :stats, :stats_set_name

    def initialize(systems, stats_set_name)
      @stats_set_name = stats_set_name
      @stats = {}
      @stats[:total] = Datum.new "Total Repositories", systems.count
      @stats[:have_owner] = Datum.new "Identified Owner", systems.has_owner.count
      @stats[:have_platform] = Datum.new "Identified Platform", systems.where.not(platform_id: Platform.default_platform_id).count
      @stats[:status_unknown] = Datum.new "Status: unknown", systems.system_status_unknown.count
      @stats[:status_online] = Datum.new "Status: online", systems.system_status_online.count
      @stats[:status_offline] = Datum.new "Status: offline", systems.system_status_offline.count
      @stats[:status_missing] = Datum.new "Status: missing", systems.system_status_missing.count
      @stats[:oai_status_unknown] = Datum.new "OAI-PMH status: unknown", systems.oai_status_unknown.count
      @stats[:oai_status_unsupported] = Datum.new "OAI-PMH status: unsupported", systems.oai_status_unsupported.count
      @stats[:oai_status_online] = Datum.new "OAI-PMH status: online", systems.oai_status_online.count
      @stats[:oai_status_offline] = Datum.new "OAI-PMH status: offline", systems.oai_status_offline.count
      @stats[:oai_status_not_enabled] = Datum.new "OAI-PMH status: not enabled", systems.oai_status_not_enabled.count
      @stats[:record_status_draft] = Datum.new "Record status: draft", systems.record_status_draft.count
      @stats[:record_status_verified] = Datum.new "Record status: verified", systems.record_status_verified.count
      @stats[:record_status_awaiting_review] = Datum.new "Record status: awaiting review", systems.record_status_awaiting_review.count
      @stats[:record_status_under_review] = Datum.new "Record status: under review", systems.record_status_under_review.count
      @stats[:record_status_archived] = Datum.new "Record status: archived", systems.record_status_archived.count
      @stats[:no_thumbnail] = Datum.new "Missing thumbnail", systems.no_thumbnail.count
    end

    def public_stats
      @stats.except(:record_status_draft, :record_status_archived, :no_thumbnail)
    end

    def total
      @stats[:total].value
    end

    def value(key)
      @stats[key.to_sym].value
    end

    def value_percentage(key, rounding_places = 0)
      Utilities::NumberUtility.get_percentage(@stats[key.to_sym].value, total, rounding_places)
    end

    def value_inverse(key)
      total - @stats[key.to_sym].value
    end

    def value_inverse_percentage(key, rounding_places = 0)
      Utilities::NumberUtility.get_percentage((total - @stats[key.to_sym].value), total, rounding_places)
    end

    def get_system_status_graph_data
      [
        [System.translated_system_status(:unknown), value_percentage(:status_unknown)],
        [System.translated_system_status(:online), value_percentage(:status_online)],
        [System.translated_system_status(:offline), value_percentage(:status_offline)],
        [System.translated_system_status(:missing), value_percentage(:status_missing)]
      ]
    end

    def get_system_status_graph_colours
      ["gray", "green", "orange", "red"]
    end

    def get_oai_graph_data
      [
        [System.translated_oai_status(:unknown), value_percentage(:oai_status_unknown)],
        [System.translated_oai_status(:unsupported), value_percentage(:oai_status_unsupported)],
        [System.translated_oai_status(:online), value_percentage(:oai_status_online)],
        [System.translated_oai_status(:offline), (value_percentage(:oai_status_offline) + value_percentage(:oai_status_not_enabled))]
      ]
    end

    def get_oai_graph_colours
      ["gray", "red", "green", "orange"]
    end
  end


end
