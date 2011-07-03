require "rack"
require "yaml"
require "rack/request"
require "rack/response"
require File.join(File.dirname(__FILE__), 'jekyll', 'helpers')
require File.join(File.dirname(__FILE__), 'jekyll', 'version')

module Rack
  class Jekyll
    @compiling = false
    
    def initialize
      config_file = '_config.yml'
      if ::File.exist?(config_file)
        config = YAML.load_file(config_file)
        @path = (config[:destination].nil? && "_site") || config[:destination]

        @files = ::Dir[@path + "/**/*"].inspect
        @files unless ENV['RACK_DEBUG']
      end
      
      @mimes = Rack::Mime::MIME_TYPES.map{|k,v| /#{k.gsub('.','\.')}$/i }
      
      if ::Dir[@path + "/**/*"].empty?
        require "jekyll"
        site = ::Jekyll::Site.new(options)
        site.process
        
        @compiling = true
      else
        @compiling = false
      end
    end
    
    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
      path_info = @request.path_info
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

        if time == @request.env['HTTP_IF_MODIFIED_SINCE']
          [@response.status, {'Last-Modified' => time}, []]
        else
          [@response.status, {"Content-Type" => mime, "Content-length" => body.length.to_s, 'Last-Modified' => time}, [body]]
        end

      else
        status, body, path_info = ::File.exist?(@path+"/404.html") ? [404,file_info(@path+"/404.html")[:body],"404.html"] : [404,"Not found","404.html"]
        mime = mime(path_info)
        if !@compiling
          [status, {"Content-Type" => mime, "Content-length" => body.length.to_s}, [body]]
        else
          [200, {"Content-Type" => "text/plain"}, ["This site is currently generating pages. Please reload this page after 10 secs."]]
        end
      end
    end    
  end
end