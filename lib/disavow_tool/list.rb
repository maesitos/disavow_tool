require 'set'

module DisavowTool
  class List

    def new; raise 'abstract!' end
    def clean_line!; raise "SubclassResponsibility" ; end

    def initialize(import_files)
      @list = Set.new
      @verbose = OPTIONS.verbose
      @verbose_hard = OPTIONS.hardcore_verbose
      import import_files if @verbose
      @original_list = @list.clone
    end

    def import(import_files)
      import_files = [import_files] if import_files.class != Array
      import_files.each do |file|
        puts "Importing file: #{file}"
        File.readlines(file).each do |line|
          line.chomp!
          if comment?(line) || line.blank?
            puts "cleaning comment or empty line: #{line}" if @verbose_hard
            next
          end
          unmodified_line = line
          clean_line!(line)
          puts import_message(unmodified_line).light_blue if @verbose_hard
          @list.add line
        end
      end
      self.try(:finished_import_hook)
    end

    def add_domain(domain, list=nil)
      list = list || @list
      if list.add? domain
        color_domain = domain.on_yellow
        puts add_url_message(color_domain).blue if @verbose
      else
        puts "Not adding #{domain}. Already in the list.".red if @verbose
      end
    end

    def add_url(url, list=nil)
      list = list || @list
      if list.add? url
        color_url = url.on_yellow
        puts add_url_message(color_url).blue if @verbose
      else
        puts "Not adding #{url}. Already in the list.".red if @verbose
      end
    end

    def delete_url(url, options={verbose:true})
      if @list.delete? url
        color_url = url.on_yellow
        puts delete_url_message(color_url).red if (@verbose && options[:verbose])
      else
        puts "Not removing #{url}. It wasn't on the list.".red if (@verbose && options[:verbose])
      end
    end

    def mass_delete_urls(urls_to_delete)
      puts mass_delete_message if @verbose_hard
      urls_to_delete.each do |link|
        color_link = link.on_yellow
        puts delete_url_message(color_link).red if @verbose
      end
      @list = @list - urls_to_delete
      puts "Deleted #{@list.count} elements.".blue if @verbose
    end

    def delete_urls_if_domains(domains)
      domains = [domains] if domains.class != Set
      init_count = self.count
      domains.each do |domain|
        puts "Analysing #{domain}" if OPTIONS.hardcore_verbose
        self.each do |link|
          if link.match(/.+#{Regexp.escape(domain)}.+/)
            self.delete_url(link, verbose:true)
          end
        end
      end
      puts "Deleted #{init_count - self.count} elements.".blue if @verbose
    end

    def summary(list=nil, original_list=nil)
      list = list || @list
      original_list = original_list || @original_list
      puts "#{message_sumary_imported} #{original_list.count}".blue
      puts "#{mensaje_sumary_before_export} #{list.count}".blue

      if @verbose
        total_imported = list - original_list
        puts "Total elements found after analysis: #{total_imported.count}".blue
        if( total_imported.count > 0) # It's a list with new links
          puts "Showing the #{total_imported.count} imported elements:".blue
          (total_imported).each_with_index do |line, i|
            puts "#{i+1}. #{line.light_blue}"
          end
        end
      end

    end

    def restore
       @list = @original_list.clone
    end

    def export(export_file=nil)
      now = Time.now.strftime("%Y%m%d%H")
      file_name = self.class.to_s.underscore + "_" + now
      export_file = export_file || EXPORT_PATH + file_name
      file = File.new(export_file, "w")
      file.puts "# Exporting #{self.class.to_s.underscore} #{ now }"
      export_write(file)
      file.close
      if @verbose
        puts "Exported #{file_name} in #{EXPORT_PATH}".red
      end
    end

    def comment?(line)
      line.match(/^#/) ? true : false
    end

    def each
      @list.each do |element|
        yield(element)
      end
    end

    def to_a
      @list.to_a
    end

    def count
      @list.count
    end

  end
end
