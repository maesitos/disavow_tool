require_relative 'list'
require 'nokogiri'
require 'open-uri'
require 'timeout'

module DisavowTool
  class ImportedLinks < List

    def initialize(import_file=nil)
      super(OPTIONS.import_files)
    end

    def remove_known_links(known_links)
      mass_delete_urls(known_links)
    end

    def remove_known_links_for_domain(domains)
      delete_urls_if_domains(domains)
    end

    def analyse(disavowed, white_list)
       "Ready to delete analize #{@list.count} remaining links"
       @list.each do |url|
         puts "#{"*"*100}\n*"
         puts "* Analysing url: #{url.on_green}"
         print "* Obtaining website's title...\r"
         puts "* Website title: #{website_title(url)}".ljust(100)
         puts "#{"*"*100}\n*"
         puts menu()
         input = $stdin.getch
         input = $stdin.getch if open_browser_option(input, url)
         case input
              when "w"
                raise "Command run with no whitelist option" if OPTIONS.whitelist == false
                white_list.add_url url
                self.delete_url url
              when "d"
                domain = disavowed.add_domain_from_url(url)
                self.delete_url url
                puts "Attempting to remove URLs with the domain #{domain}"
                self.delete_urls_if_domains(domain)
              when "u"
                disavowed.add_url(url)
                self.delete_url url
              else raise "Invalid character."
         end
       puts "\n\n#{@list.count} Remaining links to analize".blue
       end
    end

    def mass_delete_message; "Ready to delete the following links" end
    def add_url_message(url); "+++ Inserting #{url} in Imported list" end
    def delete_url_message(url); "--- Deleting #{url} from imported list" end
    def import_message(link)
      "Importing #{link} into Imported links"
    end
    def message_sumary_imported; "New links imported" end
    def mensaje_sumary_before_export; "Links pending to analyse" end

    :protected
    def clean_line!(link)
      link.gsub!(/\"/, '')  # cleaning some bad links
    end

    :private
    def menu
      message = ""
      message = "[w] to send to whitelist" if OPTIONS.whitelist
      message += "[d] to send to Disavow as a domain [u] to send to Disavow as a URL [o] to open the URL."
    end

    def open_browser_option(input, link)
      if input == "o"
          if Gem.win_platform? then system "start chrome #{link}" else system "open -a safari #{link}" end
          puts "Opening #{link}...".blue
          puts menu
          return true
        end
    end

    def website_title(url)
      begin
        Timeout::timeout(5) do
          page = Nokogiri::HTML(open(URI.escape(url)))
          return "Empty Title" if page.css("title").blank?
          return page.css("title")[0].text
        end
      rescue Timeout::Error
        return "Empty Title — Request Time Out"
      end

    end

  end
end
