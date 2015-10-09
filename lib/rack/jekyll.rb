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
        message = "Generating site: #{@source} -> #{@destination}"
        @compiling = true
        puts message
        @site.process
        load_file_list
        @compiling = false
      end

      if @auto
        require 'listen'
        require 'pathname'
        rel_destination = Pathname.new(@destination)
                              .relative_path_from(Pathname.new(@source))
                              .to_path
        puts "Auto-regenerating enabled: #{@source} -> #{@destination}"

        listener = Listen.to(@source, :ignore => %r{#{Regexp.escape(rel_destination)}}) do |modified, added, removed|
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          n = modified.length + added.length + removed.length
          message = "[#{t}] regeneration: #{n} files changed"
          @compiling = true
          puts message
          @site.process
          load_file_list
          @compiling = false
        end
        listener.start
      end
    end

    def globs(source)
      Dir.chdir(source) do
        dirs = Dir['*'].select { |x| Pathname(x).directory? }
        dirs -= ['_site']
        dirs = dirs.map { |x| "#{x}/**/*" }
        dirs += ['*']
      end
    end

    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      path_info = @request.path_info
      while @compiling
        sleep 0.1
      end
      if @files.inspect.include?(path_info)
        if path_info =~ /(\/?)$/
          if @mimes.collect {|regex| path_info =~ regex }.compact.empty?
            path_info += $1.nil? ? "/index.html" : "index.html"
          end
        end
        mime = mime(path_info)

        file  = file_info(@destination + path_info)
        body = file[:body]
        time = file[:time]
        hdrs = { 'Last-Modified'  => time }

        if time == @request.env['HTTP_IF_MODIFIED_SINCE']
          [304, hdrs, []]
        else
          hdrs.update({ 'Content-Length' => body.bytesize.to_s,
                        'Content-Type'   => mime, } )
          [@response.status, hdrs, [body]]
        end

      else
        status, body, path_info = ::File.exist?(@destination+"/404.html") ? [404,file_info(@destination+"/404.html")[:body],"404.html"] : [404,"Not found","404.html"]
        mime = mime(path_info)

        [status, {"Content-Type" => mime, "Content-Length" => body.bytesize.to_s}, [body]]
      end
    end

    private

    def load_file_list
      @files = ::Dir[@destination + "/**/*"]
    end
  end
end
