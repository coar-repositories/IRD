class IngestTasks < Thor

  namespace "ingest"
  desc "systems", "Ingests systems data"
  method_option :source, type: :string, required: true, :desc => "Source - e.g. samvera"
  method_option :dryRun, type: :boolean, required: false, :desc => "Dry Run?"
  method_option :dataFile, type: :string, required: true, :desc => "Data file (CSV)?"
  method_option :userEmail, type: :string, required: true, :desc => "Email address of user uploading data?"
  method_option :tags, type: :string, required: false, :desc => "Comma separated list of tags"

  def systems
    begin
      say("This will update your #{ENV['RAILS_ENV'].upcase} database.")
      want_to_continue = ask("Are you sure you want to continue? (y/n)")
      if want_to_continue.downcase == "y"
        Rails.logger.info "Starting System Ingest process..."
        user = User.find_by_email(options.userEmail)
        raise Exception.new("user not found with email address #{options.userEmail}") unless user.present?
        if options.tags
          tags = options.tags.split(",")
        else
          tags = []
        end
        csv_data = File.read(options.dataFile)
        Ingest::SystemIngestBatchCsvService.call!(csv_data, options.source, tags, options.dryRun, user)
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
