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
         if OPTIONS.network_requests
           print "* "+ "Obtaining website's title...\r".red.blink
           puts "* Website title: #{website_title(url)}".ljust(100)
         end
         puts "* URls with this same domain: #{urls_with_same_domain(url)}"
         puts "*\n#{"*"*100}"
         puts menu()
         input = $stdin.getch
         input = $stdin.getch if open_browser_option(input, url)
         case input
              when "w"
                raise "Command run with no whitelist option" if OPTIONS.whitelist == false
                white_list.add_url url
                self.delete_url url
              when "W"
                raise "Command run with no whitelist option" if OPTIONS.whitelist == false
                domain = white_list.add_domain_from_url(url)
                self.delete_url url
                puts "Attempting to remove URLs with the domain #{domain} from imported links to stop anaylsing"
                self.delete_urls_if_domains(domain)
              when "a"
                white_list.add_urls_with_same_domain_as url, self
              when "d"
                domain = disavowed.add_domain_from_url(url)
                self.delete_url url
                puts "Attempting to remove URLs with the domain #{domain} from imported links to stop anaylsing"
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
      message = "[w] Whitelist url [W] Whitelist the entire domain [a] whitelist as url All urls with this domain\n" if OPTIONS.whitelist
      message += "[d] Disavow as domain [u] Disavow as a URL [o] to open the URL."
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
        Timeout::timeout(SECONDS_TITTLE_REQUEST) do
          page = Nokogiri::HTML(open(URI.escape(url)))
          return "Empty Title" if page.css("title").blank?
          return page.css("title")[0].text
        end
      rescue Timeout::Error => e
        return "Empty Title — Request Time Out: #{e}"
      rescue OpenURI::HTTPError => e
        return "Empty Title. HTTP Error: #{e}"
      rescue SocketError => e
        return "Empty Title. Can't open site: #{e}"
      rescue
        return "Empty Tittle "
      end

    end

    def urls_with_same_domain(url)
      domain = URI.parse(URI.escape(url)).host
      counter = 0
      self.each do |link|
        counter += 1 if URI.parse(URI.escape(link)).host == domain
      end
      counter
    end

  end
end
