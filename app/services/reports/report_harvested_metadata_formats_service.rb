# frozen_string_literal: true
module Reports
  class ReportHarvestedMetadataFormatsService < ReportService
    require "FileUtils"

    def call
      begin
        report_folder_path = "#{@reports_folder_path}/metadata_formats"
        FileUtils.mkdir_p(report_folder_path)
        formats = {}
        systems = System.publicly_viewable
        systems.each do |system|
          unless system.formats == {}
            system.formats.each do |format|
              if formats[format[1]]
                formats[format[1]][:count] += 1
                formats[format[1]][:prefixes] << format[0]
              else
                formats[format[1]] = {count: 1, prefixes:[format[0]]}
              end
            end
          end
        end
        CSV.open("#{report_folder_path}/formats.csv", "w") do |format_csv|
          format_csv << ["schema", "count", "prefixes"]
            formats.each do |f|
            format_csv << [f[0],f[1][:count],f[1][:prefixes].uniq.join("|")]
          end
        end
        success true
      rescue Exception => e
        failure e
      end
    end
  end
end