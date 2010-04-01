require "rack"
require "rack/request"
require "rack/response"

module Rack
  class Jekyll
    
    def initialize(opts = {})
      if ::File.exist?(Dir.pwd + "/_config.yml")
        @config = ::YAML.load(::File.read(Dir.pwd + "/_config.yml"))
        @config = (@config.class == FalseClass ? {} : @config)
        if @config[:destination].nil?
          @path = opts[:destination].nil? ? "_site" : opts[:destination]
        else
          opts.merge!(@config)
          @path = @config[:destination].nil? ? "_site" : @config[:destination]
        end
      end
      @files = ::Dir[@path + "/**/*"].inspect
      p @files if ENV['RACK_DEBUG'] == "true"
      @mimes = Rack::Mime::MIME_TYPES.map{|k,v| /#{k.gsub('.','\.')}$/i }
      @compiling = false
      if ::Dir[@path + "/**/*"].empty?
        begin
          require "jekyll"
          options = ::Jekyll.configuration(opts)
          site = ::Jekyll::Site.new(options)
          @compiling = true
          site.process
        rescue LoadError => boom
          @compiling = false
        end
      end
    end
    def call(env)
      request = Request.new(env)
      path_info = request.path_info
      if @files.include?(path_info)
        if path_info =~ /(\/?)$/
          if @mimes.collect {|regex| path_info =~ regex }.compact.empty?
            path_info += $1.nil? ? "/index.html" : "index.html"
          end
        end
        mime = mime(path_info)
        body = content(::File.expand_path(@path + path_info))
        [200, {"Content-Type" => mime, "Content-length" => body.length.to_s}, [body]]
      else
        status, body, path_info = ::File.exist?(@path+"/404.html") ? [404,content(@path+"/404.html"),"404.html"] : [404,"Not found","404.html"]
        mime = mime(path_info)
        if !@compiling
          [status, {"Content-Type" => mime, "Content-Type" => body.length.to_s}, [body]]
        else
          [200, {"Content-Type" => "text/plain"}, ["This site is currently generating pages. Please reload this page after 10 secs."]]
        end
      end
    end
    def content(file)
      ::File.read(file)
    end
    def mime(path_info)
      if path_info !~ /html$/i
        ext = $1 if path_info =~ /(\.\S+)$/
        Mime.mime_type((ext.nil? ? ".html" : ext))
      else
        Mime.mime_type(".html")
      end
    end
  end
end
