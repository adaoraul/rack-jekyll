require "rack"
require "yaml"
require "rack/request"
require "rack/response"
require "thread"
require File.join(File.dirname(__FILE__), 'jekyll', 'helpers')
require File.join(File.dirname(__FILE__), 'jekyll', 'version')
require File.join(File.dirname(__FILE__), 'jekyll', 'ext')

module Rack
  class Jekyll
    def compiling?
      if @compile_queue.nil?
        false
      else
        ! @compile_queue.empty?
      end
    end

    def process(site)
      puts "Building site"
      @compile_queue = Queue.new
      @compile_queue << '.'

      Thread.new do
        site.process
        puts "Site rendering complete"
        @compile_queue.clear
      end
    end

    def read_wait_page(opts)
      if opts.has_key?(:wait_page) && ::File.exist?(opts[:wait_page])
        path = opts[:wait_page]
      else
        path = ::File.expand_path("templates/wait.html", ::File.dirname(__FILE__))
      end
      @wait_page = ::File.open(path, 'r').read
    end

    def initialize(opts = {})
      config_file = opts[:config] || "_config.yml"
      read_wait_page(opts)

      if ::File.exist?(config_file)
        config = YAML.load_file(config_file)

        @path = config['destination'] || "_site"
        @files = ::Dir[@path + "/**/*"].inspect
        @files unless ENV['RACK_DEBUG']
      end

      @mimes = Rack::Mime::MIME_TYPES.map{|k,v| /#{k.gsub('.','\.')}$/i }
      require "jekyll"
      options = ::Jekyll.configuration(opts)
      site = ::Jekyll::Site.new(options)

      process(site)
      if options['auto']
        require 'listen'
        require 'pathname'
        source = options['source']
        destination = Pathname.new(options['destination'])
                              .relative_path_from(Pathname.new(source))
                              .to_path
        puts "Auto-regenerating enabled: #{source} -> #{destination}"

        listener = Listen.to(source, :ignore => %r{#{Regexp.escape(destination)}}) do |modified, added, removed|
          unless compiling?
            t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
            n = modified.length + added.length + removed.length
            puts "[#{t}] regeneration: #{n = modified.length + added.length + removed.length} files changed"
            process(site)
            @files = ::Dir[@path + "/**/*"].inspect
          end
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

    def serve_wait_page(req)
      headers ||= {}
      headers['Content-Length'] = @wait_page.bytesize.to_s
      headers['Content-Type'] = 'text/html'
      headers['Connection'] = 'keep-alive'
      [200, headers, [@wait_page]]
    end

    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      path_info = @request.path_info
      while compiling?
        return serve_wait_page(@request)
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
          hdrs.update({ 'Content-length' => body.bytesize.to_s,
                        'Content-Type'   => mime, } )
          [@response.status, hdrs, [body]]
        end

      else
        status, body, path_info = ::File.exist?(@path+"/404.html") ? [404,file_info(@path+"/404.html")[:body],"404.html"] : [404,"Not found","404.html"]
        mime = mime(path_info)

        [status, {"Content-Type" => mime, "Content-length" => body.bytesize.to_s}, [body]]
      end
    end
  end
end
