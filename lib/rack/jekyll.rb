require "rack"
require "yaml"
require "rack/request"
require "rack/response"
require File.join(File.dirname(__FILE__), 'jekyll', 'helpers')
require File.join(File.dirname(__FILE__), 'jekyll', 'version')
require File.join(File.dirname(__FILE__), 'jekyll', 'ext')

module Rack
  class Jekyll
    @compiling = false

    def initialize(opts = {})
      config_file = '_config.yml'
      if ::File.exist?(config_file)
        config = YAML.load_file(config_file)
        @path = (config['destination'].nil? && "_site") || config['destination']

        @files = ::Dir[@path + "/**/*"].inspect
        @files unless ENV['RACK_DEBUG']
      end

      @mimes = Rack::Mime::MIME_TYPES.map{|k,v| /#{k.gsub('.','\.')}$/i }
      require "jekyll"
      options = ::Jekyll.configuration(opts)
      site = ::Jekyll::Site.new(options)
      if ::Dir[@path + "/**/*"].empty?
        site.process
        @compiling = true
      else
        @compiling = false
      end
      if options['auto']
        require 'directory_watcher'
        require 'pathname'
        source, destination = options['source'], options['destination']
        puts "Auto-regenerating enabled: #{source} -> #{destination}"

        dw = DirectoryWatcher.new(source)
        dw.interval = 1
        dw.glob = globs(source)

        dw.add_observer do |*args|
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          puts "[#{t}] regeneration: #{args.size} files changed"
          site.process
        end

        dw.start
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
      @files = ::Dir[@path + "/**/*"].inspect if @files == "[]"
      if @files.include?(path_info)
        if path_info =~ /(\/?)$/
          if @mimes.collect {|regex| path_info =~ regex }.compact.empty?
            path_info += $1.nil? ? "/index.html" : "index.html"
          end
        end
        mime = mime(path_info)

        file  = file_info(@path + path_info)
        body = file[:body]
        time = file[:time]
        hdrs = { 'Last-Modified'  => time }

        if time == @request.env['HTTP_IF_MODIFIED_SINCE']
          [304, hdrs, []]
        else
          hdrs.update({ 'Content-length' => body.bytesize.to_s,
                        'Content-Type'   => mime, } )
          [@response.status, hdrs, [body]]
        end

      else
        status, body, path_info = ::File.exist?(@path+"/404.html") ? [404,file_info(@path+"/404.html")[:body],"404.html"] : [404,"Not found","404.html"]
        mime = mime(path_info)
        if !@compiling
          [status, {"Content-Type" => mime, "Content-length" => body.bytesize.to_s}, [body]]
        else
          @compiling = ::Dir[@path + "/**/*"].empty?
          [200, {"Content-Type" => "text/plain"}, ["This site is currently generating pages. Please reload this page after a couple of seconds."]]
        end
      end
    end
  end
end
