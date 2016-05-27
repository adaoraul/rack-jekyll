require "rack"
require "jekyll"

require_relative "jekyll/filehandler"
require_relative "jekyll/utils"
require_relative "jekyll/version"

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

      @files = FileHandler.new(@destination)
      @site = ::Jekyll::Site.new(@config)

      if @files.empty? || @force_build
        process("Generating site: #{@source} -> #{@destination}")
      end

      if @auto
        require 'listen'
        require 'listen/version'
        require 'pathname'

        puts "Auto-regeneration enabled: #{@source} -> #{@destination}"

        source_abs = ::File.expand_path(@source)
        dest_abs   = ::File.expand_path(@destination)
        relative_path_to_dest = Pathname.new(dest_abs)
                                .relative_path_from(Pathname.new(source_abs))
                                .to_path
        ignore_pattern = %r{#{Regexp.escape(relative_path_to_dest)}}

        listener = Listen.to(@source, :ignore => ignore_pattern) do |modified, added, removed|
          t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          n = modified.length + added.length + removed.length
          process("[#{t}] Regenerating: #{n} file(s) changed")
        end
        listener.start  unless Listen::VERSION =~ /\A[0-1]\./
      end
    end

    def call(env)
      while @compiling
        sleep 0.1
      end

      request = Rack::Request.new(env)

      uri = request.path_info
      if (uri.include? "." || uri == "/")
        filename = @files.get_filename(uri)
      else
        filename = @files.get_filename(uri << ".html")
      end

      if filename
        media_type = Utils.media_type(filename)

        file = Utils.file_info(filename)
        body = file[:body]
        time = file[:time]
        hdrs = { "Last-Modified" => time }

        if time == request.env["HTTP_IF_MODIFIED_SINCE"]
          response = [304, hdrs, []]
        else
          hdrs.update({ "Content-Length" => body.bytesize.to_s,
                        "Content-Type"   => media_type })
          response = [200, hdrs, [body]]
        end

      else
        body = not_found_message
        hdrs = { "Content-Length" => body.bytesize.to_s,
                 "Content-Type"   => "text/html" }
        response = [404, hdrs, [body]]
      end

      request.head? ? remove_body(response) : response
    end

    private

    def process(message = nil)
      @compiling = true
      puts message  if message
      @site.process
      @files.update
      @compiling = false
    end

    def not_found_message
      custom_404 || default_404
    end

    def default_404
      "Not found"
    end

    def custom_404
      filename = @files.get_filename("/404.html")

      filename ? Utils.file_info(filename)[:body] : nil
    end

    def remove_body(response)
      status, headers, _body = response

      [status, headers, []]
    end
  end
end
