require "rack"
require "rack/request"
require "rack/response"

module Rack
  class Jekyll
    
    def initialize(opts = {})
      @path = opts[:path].nil? ? "_site" : opts[:path]
      @files = Dir[@path + "/**/*"].inspect
      @mimes = Rack::Mime::MIME_TYPES.reject { /\.html?/i }.map {|k,v| /(#{k.gsub(/\./,'\.')})$/i }
      if Dir[@path + "/**/*"].empty?
        begin
          require "jekyll"
          options = ::Jekyll.configuration(opts)
          site = ::Jekyll::Site.new(options)
          site.process
        rescue LoadError => boom
        end
      end
    end
    
    def call(env)
      request = Request.new(env)
      path_info = request.path_info
      if @files.include?(path_info)
        if path_info =~ /(\/?)$/
          if !@mimes.collect {|regex| path_info =~ regex }.empty?
            path_info += $1.nil? ? "/index.html" : "index.html"
          end
        end
        mime = mime(path_info)
        body = content(::File.expand_path(@path + path_info))
        [200, {"Content-Type" => mime, "Content-length" => body.length.to_s}, [body]]
      else
        status, body, path_info = ::File.exist?(@path+"/404.html") ? [200,content(@path+"/404.html"),"404.html"] : [404,"Not found","404.html"]
        mime = mime(path_info)
        [status, {"Content-Type" => mime, "Content-Type" => body.length.to_s}, [body]]
      end
    end
    def content(file)
      ::File.read(file)
    end
    def mime(path_info)
      ext = $1 if path_info =~ /(\.\S+)$/
      Mime.mime_type((ext.nil? ? ".html" : ext))
    end
  end
end
