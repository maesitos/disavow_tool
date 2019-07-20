require 'set'
module DisavowTool
  class List

    def new; raise 'abstract!' end
    def clean_line!; raise "SubclassResponsibility" ; end

    def initialize(import_file)
      @list = Set.new
      @verbose = Parameters::OPTIONS[:verbose]
      import import_file
      @original_list = @list.clone
    end

    def import(import_files)
      import_files = [import_files] if import_files.class != Array
      import_files.each do |file|
        File.readlines(file).each do |line|
          line.chomp!
          unmodified_line = line
          clean_line!(line)
          puts import_message(unmodified_line).light_blue if @verbose
          @list.add line
        end
      end
    end

    def add_domain(domain, list=nil)
      add_url(domain,list)
    end

    def add_url(url, list=nil)
      list = list || @list
      if @list.add? url
        color_url = url.on_yellow
        puts add_url_message(color_url).blue if @verbose
      else
        puts "Not adding #{url}. Already in the list.".red if @verbose
      end
    end

    def delete_url(url)
      if @list.delete? url
        color_url = url.on_yellow
        puts delete_url_message(color_url).red if @verbose
      else
        puts "Not removing #{url}. It wasn't on the list.".red if @verbose
      end
    end

    def mass_delete_urls(urls_to_delete)
      puts mass_delete_message
      urls_to_delete.each do |link|
        color_link = link.on_yellow
        puts delete_url_message(color_link).red if @verbose
      end
      @list = @list - urls_to_delete
    end

    def delete_urls_if_domains(domains)
      domains = [domains] if domains.class != Set
      domains.each do |domain|
        puts "Analysing #{domain}" if Parameters::OPTIONS[:hardcore_verbose]
        self.each do |link|
          if link.match(/.+#{Regexp.escape(domain)}.+/)
            self.delete_url(link)
          end
        end
      end
    end

    def sumary
      puts "#{mensaje_sumary_importados} #{@original_list.count}".blue
      puts "#{mensaje_sumary_restantes} #{@list.count}".blue
    end

    def restore
       @list = @original_list.clone
    end

    def export(export_file=nil)
      now = Time.now.strftime("%Y%m%d%H")
      file_name = self.class.to_s.underscore + "_" + now
      export_file = export_file || EXPORT_PATH + file_name
      file = File.new(export_file, "w")
      file.puts "# Export #{self.class.to_s.underscore} #{ now }"
      export_write(file)
      file.close
      if @verbose
        puts "Exported #{file_name} in #{EXPORT_PATH}".blue
      end
    end

    def export_write(file)
      file.puts "# Whitelist"
      file.puts self.to_a
    end

    def each
      @list.each do |element|
        yield(element)
      end
    end

    def to_a
      @list.to_a
    end

  end
end
