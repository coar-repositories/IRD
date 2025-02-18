class DBTasks < Thor
  namespace "db"

  desc "dump_db_to_csv_files", "Dump database to CSV files"
  method_option :dbName, type: :string, required: true, :desc => "Database name"
  method_option :csvFolderPath, type: :string, required: true, :desc => "csv folder path"

  def dump_db_to_csv_files
    begin
      models = [User, Role, Platform]
      models.each do |model|
        csv_file_path = "#{options.csvFolderPath}/#{model.name.downcase}.csv"
        Rails.logger.info "Downloading #{model.name} to #{csv_file_path}"
        CSV.open(csv_file_path, "wb") do |csv|
          columns = model.attribute_names
          csv << columns
          model.all.each do |model_instance|
            row = []
            columns.each {|column| row << model_instance.attributes[column]}
            csv << row
          end
        end
      end
    rescue Exception => e
      Rails.logger e.message
    end
  end

  desc "dump_db", "Dump postgres database (data and structure) to a file"
  method_option :dbName, type: :string, required: true, :desc => "Database name"

  def dump_db
    begin
      command = "pg_dump --dbname=postgresql://#{ENV['IRD_DB_USERNAME']}:#{ENV['IRD_DB_PASSWORD']}@#{ENV['IRD_DB_HOST']}:#{ENV['IRD_DB_PORT']}/#{options.dbName} --format=tar > #{Rails.root.join("data", "dump", "#{options.dbName}-dump.sql")}"
      exec command
    rescue Exception => e
      Rails.logger.error e.message
    end
  end

  desc "restore_db", "Restore postgres database (data and structure) from a file"
  method_option :dbName, type: :string, required: true, :desc => "Database name"
  method_option :defaultDbName, type: :string, required: true, :desc => "Default Database to connect to (e.g. 'postgres' or 'defaultdb')"

  def restore_db
    begin
      say("This will overwrite your entire database.")
      want_to_continue = ask("Are you sure you want to continue? (y/n)")
      if want_to_continue.downcase == 'y'
        command = "psql --host=#{ENV['IRD_DB_HOST']} --port=#{ENV['IRD_DB_PORT']} --username=#{ENV['IRD_DB_USERNAME']} --dbname=#{options.defaultDbName} --command='DROP DATABASE IF EXISTS #{options.dbName};'"
        command += " && psql --host=#{ENV['IRD_DB_HOST']} --port=#{ENV['IRD_DB_PORT']} --username=#{ENV['IRD_DB_USERNAME']} --dbname=#{options.defaultDbName} --command='CREATE DATABASE #{options.dbName};'"
        command += " && pg_restore --dbname=postgresql://#{ENV['IRD_DB_USERNAME']}:#{ENV['IRD_DB_PASSWORD']}@#{ENV['IRD_DB_HOST']}:#{ENV['IRD_DB_PORT']}/#{options.dbName} --format=tar < #{Rails.root.join("data", "dump", "#{options.dbName}-dump.sql")}"
        exec command
      end
    rescue Exception => e
      Rails.logger e.message
    end
  end
end

