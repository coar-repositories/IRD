# frozen_string_literal: true

module Snapshots
  class SystemSnapshotCreationService < ApplicationService
    def call(system_id,user)
      begin
        Rails.logger.debug "Starting system snapshot creation"
        system = System.find(system_id)
        snapshot = system.create_snapshot!(
          user: user
        )
        success snapshot
      rescue Exception => exception
        Rails.logger.error exception.message
        failure e
      end
    end
  end
end

# system.create_snapshot!(
#   identifier: "two",
#   user: User.system_user,
#   metadata: {
#     comment: "has theses patents and 2 tags"
#   }
# )