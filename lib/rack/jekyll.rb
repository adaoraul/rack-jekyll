require "rack"
require "rack/request"
require "rack/response"

module Rack
  class Jekyll
    
    def initialize(opts = {})
      @path = opts[:path].nil? ? "_site" : opts[:path]
      @files = Dir[@path + "/**/*"].inspect
      if Dir[@path + "/**/*"].empty?
        system("jekyll #{@path}")
      end
    end
    
    def call(env)
      request = Request.new(env)
      path_info = request.path_info
      ext = ''
      if @files.include?(path_info)
        if path_info =~ /(\/?)$/
          if path_info !~ /\.(css|js|jpe?g|gif|png|mov|mp3)$/i
            path_info += $1.nil? ? "/index.html" : "index.html"
          end
          ext = $1 if path_info =~ /(\.\S+)$/i 
        end
        mime = Mime.mime_type(ext)
        body = ::File.read(::File.expand_path(@path + path_info))
        [200, {"Content-Type" => mime, "Content-length" => body.length.to_s}, [body]]
      else
        ext = $1 if path_info =~ /(\.\S+)$/i
        mime = Mime.mime_type(ext)
        status = 404
        body = "Not found"
        if ::File.exist?(@path + "/404.html")
          status = 200
          body = ::File.read(@path + "/404.html")
          mime = Mime.mime_type(".html")
        end
        [status, {"Content-Type" => mime, "Content-Type" => body.length.to_s}, [body]]
      end
    end

  end
end
