# frozen_string_literal: true
module Reports
  class ReportService < ApplicationService
    def initialize(propagate = true)
      super(propagate)
      @reports_folder_path = "#{__dir__}/../../../data/reports"
    end
  end
end