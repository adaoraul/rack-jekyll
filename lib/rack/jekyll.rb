require "rack"
require "jekyll"
require "rack/request"
require "rack/response"
require File.join(File.dirname(__FILE__), 'jekyll', 'helpers')
require File.join(File.dirname(__FILE__), 'jekyll', 'version')
require File.join(File.dirname(__FILE__), 'jekyll', 'ext')

module Rack
  class Jekyll

    attr_reader :config, :destination

    # Initializes a new Rack::Jekyll site.
    #
    # Options:
    #
    # +:config+::      use given config file (default: "_config.yml")
    #
    # +:force_build+:: whether to always generate the site at startup, even
    #                  when the destination path is not empty (default: +false+)
    #
    # +:auto+::        whether to watch for changes and rebuild (default: +false+)
    #
    # Other options are passed on to Jekyll::Site.
    def initialize(options = {})
      overrides = options.dup
      @compiling = false
      @force_build = overrides.fetch(:force_build, false)
      @auto        = overrides.fetch(:auto, false)

      overrides.delete(:force_build)
      overrides.delete(:auto)
      @config = ::Jekyll.configuration(overrides)

      @destination = @config["destination"]
      @source      = @config["source"]

      load_file_list
      puts @files.inspect if ENV['RACK_DEBUG']

      @mimes = Rack::Mime::MIME_TYPES.map{|k,v| /#{k.gsub('.','\.')}$/i }

      @site = ::Jekyll::Site.new(@config)

      if ::Dir[@destination + "/**/*"].empty? || @force_build
        process("Generating site: #{@source} -> #{@destination}")
      end

      if @auto
        require 'listen'
        require 'listen/version'
        require 'pathname'

        puts "Auto-regeneration enabled: #{@source} -> #{@destination}"

        source_abs = ::File.expand_path(@source)
        dest_abs   = ::File.expand_path(@destination)
        relative_path_to_dest = Pathname.new(dest_abs)
                                .relative_path_from(Pathname.new(source_abs))
                                .to_path
        ignore_pattern = %r{#{Regexp.escape(relative_path_to_dest)}}

        listener = Listen.to(@source, :ignore => ignore_pattern) do |modified, added, removed|
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          n = modified.length + added.length + removed.length
          process("[#{t}] Regenerating: #{n} file(s) changed")
        end
        listener.start  unless Listen::VERSION =~ /\A[0-1]\./
      end
    end

    def call(env)
      while @compiling
        sleep 0.1
      end

      request = Rack::Request.new(env)

      filename = get_filename(request.path_info)

      if filename
        mime = mime(filename)

        file  = file_info(filename)
        body = file[:body]
        time = file[:time]
        hdrs = { "Last-Modified" => time }

        if time == request.env["HTTP_IF_MODIFIED_SINCE"]
          response = [304, hdrs, []]
        else
          hdrs.update({ "Content-Length" => body.bytesize.to_s,
                        "Content-Type"   => mime })
          response = [200, hdrs, [body]]
        end

      else
        body = if ::File.exist?(@destination + "/404.html")
                 file_info(@destination + "/404.html")[:body]
               else
                 "Not found"
               end
        hdrs = { "Content-Length" => body.bytesize.to_s,
                 "Content-Type"   => "text/html" }
        response = [404, hdrs, [body]]
      end

      response
    end

    private

    def load_file_list
      @files = ::Dir[@destination + "/**/*"]
    end

    def process(message = nil)
      @compiling = true
      puts message  if message
      @site.process
      load_file_list
      @compiling = false
    end

    def get_filename(path)
      if @mimes.collect {|regex| path =~ regex }.compact.empty?
        normalized = ::File.join(path, "index.html")
      else
        normalized = path.dup
      end

      if @files.inspect.include?(normalized)
        filename = ::File.join(@destination, normalized)
      else
        filename = nil
      end

      filename
    end
  end
end
