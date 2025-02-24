class IngestTasks < Thor

  namespace "ingest"
  desc "systems", "Ingests systems data"
  method_option :source, type: :string, required: true, :desc => "Source - e.g. Samvera"
  method_option :dryRun, type: :boolean, required: false, :desc => "Dry Run?"
  method_option :dataFile, type: :string, required: true, :desc => "Data file (CSV)?"

  def systems
    begin
      say("This will update your #{ENV['RAILS_ENV'].upcase} database.")
      want_to_continue = ask("Are you sure you want to continue? (y/n)")
      if want_to_continue.downcase == 'y'
        Rails.logger.info "Starting System Ingest process..."
        Ingest::SystemIngestBatchCsvService.call!(options.dataFile, options.source, options.dryRun)
      end
    rescue Exception => e
      Rails.logger.error e.message
    end
    Rails.logger.info "System Ingest process complete"
  end

  desc "ror", "Ingests ROR data"
  method_option :dataFile, type: :string, required: true, :desc => "File path to JSON data?"

  def ror
    Ingest::RorIngestBatchService.call!(options.dataFile)
  end
end
