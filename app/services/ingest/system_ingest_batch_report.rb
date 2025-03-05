# frozen_string_literal: true

module Ingest

  class BatchItemReport
    attr_reader :batch_item_number, :message

    def initialize(batch_item_number, message)
      @batch_item_number = batch_item_number
      @message = [message]
    end

    def report
      "Batch item: #{@batch_item_number}: #{@message}"
    end
  end

  class SystemIngestBatchReport
    attr_reader :records_created, :records_updated, :records_unchanged, :records_not_updated, :errors

    def initialize
      @records_created = []
      @records_updated = []
      @records_unchanged = []
      @records_not_updated = []
      @errors = []
    end

    def add_record_created(system_id)
      @records_created << system_id
    end

    def add_record_updated(system_id)
      @records_updated << system_id
    end

    def add_record_unchanged(batch_item_report)
      @records_unchanged << batch_item_report
    end

    def add_record_not_updated(batch_item_report)
      @records_not_updated << batch_item_report
    end

    def add_error(batch_item_report)
      @errors << batch_item_report
    end

    def report
      {
        records_created: @records_created.count,
        records_updated: @records_updated.count,
        records_unchanged: @records_unchanged.count,
        records_not_updated: @records_not_updated.count,
        errors: @errors.count
      }
    end
  end
end
