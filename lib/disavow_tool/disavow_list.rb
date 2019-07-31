require_relative 'list'
require_relative 'domain_and_url'
require 'uri'

module DisavowTool
  class DisavowList < List
    include DomainAndUrl

    def initialize(import_files=nil)
      import_files = import_files || OPTIONS.disavow_files
      super(import_files)
    end

    def import_message(domain)
      "Importing #{is_url?(domain).to_s} #{remove_domain_prefix(domain)} into Disavow list"
    end
    def add_url_message(url)
      "+++ Inserting #{is_url?(url).to_s} #{url.on_yellow} in Disavow"
    end
    def message_sumary_imported; "Disavowed elements imported" end
    def mensaje_sumary_before_export; "Disavow elements before exporting" end

    def message_sumary_links_imported; "Disavowed URLs:" end
    def message_sumary_domains_imported; "Disavowed Domains:" end

    def export_write(file)
      file.puts "# Disavow"
      super(file)
      puts "Writing #{total_elements} elements into the Disavow file".blue if @verbose
    end

  end
end
