require "rack"
require "jekyll"
require "yaml"
require "rack/request"
require "rack/response"
require File.join(File.dirname(__FILE__), 'jekyll', 'helpers')
require File.join(File.dirname(__FILE__), 'jekyll', 'version')
require File.join(File.dirname(__FILE__), 'jekyll', 'ext')

module Rack
  class Jekyll

    attr_reader :config

    def initialize(opts = {})
      @compiling = false
      @force_build = opts.fetch(:force_build, false)

      config_file = opts[:config] || "_config.yml"
      if ::File.exist?(config_file)
        config = YAML.load_file(config_file)

        @path = config['destination'] || "_site"
        @files = ::Dir[@path + "/**/*"].inspect
        puts @files.inspect if ENV['RACK_DEBUG']
      end

      @mimes = Rack::Mime::MIME_TYPES.map{|k,v| /#{k.gsub('.','\.')}$/i }
      options = ::Jekyll.configuration(opts)
      site = ::Jekyll::Site.new(options)

      @config = options

      if ::Dir[@path + "/**/*"].empty? || @force_build
        @compiling = true
        puts "Generating site: #{options['source']} -> #{@path}"
        site.process
        @compiling = false
      end

      if options['auto']
        require 'listen'
        require 'pathname'
        source = options['source']
        destination = Pathname.new(options['destination'])
                              .relative_path_from(Pathname.new(source))
                              .to_path
        puts "Auto-regenerating enabled: #{source} -> #{destination}"

        listener = Listen.to(source, :ignore => %r{#{Regexp.escape(destination)}}) do |modified, added, removed|
          @compiling = true
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          n = modified.length + added.length + removed.length
          puts "[#{t}] regeneration: #{n = modified.length + added.length + removed.length} files changed"
          site.process
          @files = ::Dir[@path + "/**/*"].inspect
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
          hdrs.update({ 'Content-Length' => body.bytesize.to_s,
                        'Content-Type'   => mime, } )
          [@response.status, hdrs, [body]]
        end

      else
        status, body, path_info = ::File.exist?(@path+"/404.html") ? [404,file_info(@path+"/404.html")[:body],"404.html"] : [404,"Not found","404.html"]
        mime = mime(path_info)

        [status, {"Content-Type" => mime, "Content-Length" => body.bytesize.to_s}, [body]]
      end
    end
  end
end
