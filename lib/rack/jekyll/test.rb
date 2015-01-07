require "rack"
require "rack/request"
require "rack/response"
require File.join(File.dirname(__FILE__), 'ext')

module Rack
  class Jekyll
    class Test
      def initialize
        @files = %w{_fake/ _fake/index.html _fake/3/2/1/helloworld/index.html _fake/css/test.css _fake/js/test.js _fake/js/test.min.js}
        @mimes = Rack::Mime::MIME_TYPES.reject{|k,v|k=~%r{html?}}.map{|k,v|%r{#{k.gsub('.','\.')}$}i}
      end

      def call(env)
        request = Request.new(env)
        path_info = "_fake" + request.path_info
        if @files.include?(path_info)
          if path_info =~ /(\/?)$/
            if @mimes.collect {|regex| path_info =~ regex }.compact.empty?
              path_info += $1.nil? ? "/index.html" : "index.html"
            end
          end
          mime = mime(path_info)
          body = "Jekyll/Rack"
          time = "Thu, 01 Apr 2010 15:27:52 GMT"
          if time == request.env['HTTP_IF_MODIFIED_SINCE']
            [304, {'Last-Modified' => time}, []]
          else
            [200, {"Content-Type" => mime, "Content-Length" => body.bytesize.to_s, "Last-Modified" => "Thu, 01 Apr 2010 15:27:52 GMT"}, [body]]
          end
        else
          status, body, path_info = [404,"Not found","404.html"]
          mime = mime(path_info)
          [status, {"Content-Type" => mime, "Content-Type" => body.bytesize.to_s}, [body]]
        end
      end
      def mime(path_info)
        ext = $1 if path_info =~ /(\.[\S&&[^.]]+)$/
        Mime.mime_type((ext.nil? ? ".html" : ext))
      end
    end
  end
end
