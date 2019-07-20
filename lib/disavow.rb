#!/usr/bin/ruby
require 'colorize'
require 'io/console'
require_relative 'disavow_tool/config'
require_relative 'disavow_tool/version'
require_relative 'disavow_tool/command_options.rb'
require_relative 'disavow_tool/disavow_list.rb'
require_relative 'disavow_tool/white_list.rb'
require_relative 'disavow_tool/imported_links.rb'

module DisavowTool
  p OPTIONS
  puts "Importing new links".blue if OPTIONS.verbose
  imported_links = ImportedLinks.new

  puts "Importing Disavowed links".blue if OPTIONS.verbose
  disavowed = DisavowList.new

  if OPTIONS.whitelist
    puts "Importing Whitelist links".blue if OPTIONS.verbose
    white_list = WhiteList.new
    puts "Cleagning links already in whitelist".blue if OPTIONS.verbose
    imported_links.remove_known_links(white_list)
  end


  puts "Cleagning links already in Disavow".blue if OPTIONS.verbose
  imported_links.remove_known_links(disavowed.links)

  puts "Cleagning links with a domain existingin in Disavow".blue if OPTIONS.verbose
  imported_links.remove_known_links_for_domain(disavowed.domains)

  imported_links.sumary

  imported_links.analyse(disavowed, white_list)

  disavowed.export
  white_list.export
  # # We'll only analyse links that are not in
  # # the Whitelist nor at Disavowed
  # knwon_links = (@disavowed_links + @whitelisted_links).uniq
  # @imported_links.each do |imported_link|
  #   knwon_links.each do |knwon_link|
  #     if imported_link == knwon_link
  #       @imported_links.delete(knwon_link)
  #       if Parameters::OPTIONS[:verbose]
  #         puts "URL #{knwon_link} already in Disavowed or Whitelist".green
  #         puts "  Remowing #{knwon_link.on_green} from imported links.".red
  #       end
  #     end
  #   end
  # end
  #
  # @imported_links.each do |imported_link|
  #   domain2delete = @disavowed_domains.find do |disavowed_domain|
  #     imported_link.match(/.+#{Regexp.escape(disavowed_domain)}.+/)
  #   end
  #
  #   next if domain2delete.nil?
  #   @disavowed_domains.delete(domain2delete) # Carefull
  #   if Parameters::OPTIONS[:verbose]
  #     puts "Found imported links with the already in Disavowed domain #{domain2delete}  ".green
  #   end
  #
  #   @imported_links.reject! do |candidate_to_remove|
  #     if candidate_to_remove.match(/.+#{Regexp.escape(domain2delete)}.+/)
  #       puts "  Removing #{candidate_to_remove.on_yellow} from imported links.".red if Parameters::OPTIONS[:verbose]
  #       true
  #     end
  #   end
  # end
  #
  # if  Parameters::OPTIONS[:verbose]
  #   puts "\n\n*********\n* SUMARY\n*********"
  #   puts "Imported:"
  #   puts " * #{DISAVOWED_LINKS.count} disavowed links"
  #   puts " * #{DISAVOWED_DOMAINS.count} disavowed domains"
  #   puts " * #{IMPORTED_LINKS.count} links to analyse"
  #   puts " * #{WHITELISTED_LINKS.count} whitelisted links"
  #   puts "Liks Discated: #{IMPORTED_LINKS.count - @imported_links.count}"
  #   puts "Links Pending to be Verified: #{@imported_links.count}".green
  # end
  #
  #
  # #Reset vars
  # @disavowed_links = DISAVOWED_LINKS.clone
  # @disavowed_domains = DISAVOWED_DOMAINS.clone
  # @whitelisted_links = WHITELISTED_LINKS.clone
  #
  # @imported_links.each do |link|
  #   puts "\n\n#{"*"*100}\n* Analysing url: #{link.on_green}\n#{"*"*100}"
  #   puts "[w] to send to whitelist [d] to send to Disavow as a domain [u] to send to Disavow as a URL [o] to open the URL."
  #   input = $stdin.getch
  #   if input == "o"
  #     if Gem.win_platform? then system "start chrome #{link}" else system "open -a safari #{link}" end
  #     puts "Opening #{link}...".blue
  #     puts "Continue with options [w], [d] or [u]"
  #     input = $stdin.getch
  #   end
  #   case input
  #     when "w"
  #       @whitelisted_links << link
  #       puts "+++ Inserting #{link.on_green} in #{"whitelist".on_green}".light_blue if Parameters::OPTIONS[:verbose]
  #
  #     when "d"
  #       host_to_disavow = URI.parse(link).host
  #       puts "+++ Inserting #{host_to_disavow.on_yellow} in #{"disavowed Domains".on_yellow}".light_blue if Parameters::OPTIONS[:verbose]
  #       @disavowed_domains << host_to_disavow
  #
  #       puts "---  Removing #{link} from pending to verify list.".red if Parameters::OPTIONS[:verbose]
  #       @imported_links.delete link
  #
  #       puts "Looking for links with the domain #{host_to_disavow} in the links pending to verified...".blue
  #       links_without_target_domain = @imported_links.reject{|imported_link| host_to_disavow == URI.parse(imported_link).host}
  #       links_found = @imported_links.count - links_without_target_domain.count
  #
  #       if(links_found > 0)
  #         puts "#{links_found} links pending to veryfy with the domain #{host_to_disavow}".green
  #         (@imported_links - links_without_target_domain).each do |link_to_remove|
  #           puts "--- Removing #{link_to_remove.on_yellow} from pending to verify list.".red if Parameters::OPTIONS[:verbose]
  #           @imported_links.delete link_to_remove
  #         end
  #       else
  #         puts "No links pending to verify with the domain #{host_to_disavow}".light_blue if Parameters::OPTIONS[:verbose]
  #       end
  #
  #     when "u"
  #       @disavowed_links << link
  #       @imported_links.delete link
  #       puts "+++ Inserting #{link.on_yellow} in #{"disavowed links".on_yellow}".light_blue if Parameters::OPTIONS[:verbose]
  #     else raise "Invalid character."
  #   end
  # end
  #
  # if  Parameters::OPTIONS[:verbose]
  #   puts "\n\n*********\n* SUMARY\n*********"
  #   puts "Links added to whitelist:"
  #   (@whitelisted_links - WHITELISTED_LINKS).each{ |whitelisted| puts "New whitelisted #{whitelisted}".green}
  #
  #   puts "Links added to disavow:"
  #   (@disavowed_links - DISAVOWED_LINKS).each{ |disavowed_link| puts "New disavowed link #{disavowed_link}".red}
  #
  #   puts "Domain added to disavow:"
  #   (@disavowed_domains - DISAVOWED_DOMAINS).each{ |disavowed_domain| puts "New disavowed link #{disavowed_domain}".red}
  #
  # end



end
