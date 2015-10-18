module Rack
  class Jekyll
    def mime(filename)
      ext = ::File.extname(filename)

      Rack::Mime.mime_type(ext)
    end

    def file_info(path)
      expand_path = ::File.expand_path(path)
      ::File.open(expand_path, 'r') do |f|
        {:body => f.read, :time => f.mtime.httpdate, :expand_path => expand_path}
      end
    end
  end
end
