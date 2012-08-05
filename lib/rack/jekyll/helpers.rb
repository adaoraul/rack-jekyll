module Rack
  class Jekyll
    def mime(path_info)
      if path_info !~ /html$/i
        ext = $1 if path_info =~ /(\.[\S&&[^.]]+)$/
        Mime.mime_type((ext.nil? ? ".html" : ext))
      else
        Mime.mime_type(".html")
      end
    end

    def file_info(path)
      expand_path = ::File.expand_path(path)
      ::File.open(expand_path, 'r') do |f|
        {:body => f.read, :time => f.mtime.httpdate, :expand_path => expand_path}
      end
    end
  end
end
