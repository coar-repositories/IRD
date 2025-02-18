# frozen_string_literal: true

module Stats
  class SystemSetStatsCollectionService < ApplicationService
    def call(system_set_stats_array)
      begin
        success CSV.generate(col_sep: ',') do |csv|
          csv << ['name', 'repositories', 'system online %', 'oai-pmh online %', 'software_platform_identified %']
          system_set_stats_array.each do |stats_set|
            row = []
            row << stats_set.stats_set_name
            row << stats_set.total
            row << stats_set.value_percentage(:status_online, 1)
            row << stats_set.value_percentage(:oai_status_online, 1)
            row << stats_set.value_percentage(:have_platform, 1)
            csv << row
          end
        end
      rescue Exception => e
        failure e
      end
    end
  end
end
