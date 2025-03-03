# frozen_string_literal: true
module Curation
  class DeduplicationService < ApplicationService
    def call
      begin
        pair_count = 0
        # potential_duplicates = System.not_record_status_archived.select(:url).group(:url).having("count(*) > 1")
        potential_duplicates = Normalid.select(:url).group(:url).having("count(*) > 1")
        potential_duplicates.each do |potential_duplicate|
          systems = Normalid.where(url: potential_duplicate.url).extract_associated(:system)
          if systems.count > 1
            systems.sort! { |a, b| (a.updated_at <=> b.updated_at) }
            keeper = systems[0]
            systems[1..].each do |doppelganger|
              unless keeper.record_status == :archived || doppelganger.record_status == :archived
                pair_count += 1
              end
              keeper.update_from_duplicate_system(doppelganger)
              keeper.save!
              doppelganger.label_list.add('duplicate')
              doppelganger.record_status = :archived
              doppelganger.save!
            end
          end
        end
        Rails.logger.info "Deduplicated #{pair_count} systems"
        success pair_count
      rescue Exception => e
        Rails.logger.error("Error in DeduplicationService: #{e.message}")
        failure e
      end
    end
  end
end