require "rack"
require "rack/request"
require "rack/response"

module Rack
  class Jekyll
    class Test 
      attr_accessor :config, :url
      def initialize(config)
        @url = ''
        @config = config
        @files = %w{_fake/ _fake/index.html _fake/3/2/1/helloworld/index.html _fake/css/test.css _fake/js/test.js}
      end
    
      def call(env)
        request = Request.new(env)
        path_info = "_fake" + request.path_info
        ext = ''
        if @files.include?(path_info)
          if path_info =~ /(\/?)$/
            if path_info !~ /\.(css|js|jpe?g|gif|png|mov|mp3)$/i
              path_info += $1.nil? ? "/index.html" : "index.html"
            end
            ext = $1 if path_info =~ /(\.\S+)$/i 
          end
          mime = Mime.mime_type(ext)
          body = "Jekyll/Rack"
          [200, {"Content-Type" => mime, "Content-length" => body.length.to_s}, [body]]
        else
          ext = $1 if path_info =~ /(\.\S+)$/i
          mime = Mime.mime_type(ext)
          [404, {"Content-Type" => mime}, ["Not found"]]
        end
      end
    end
  end
end
