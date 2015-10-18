module Rack
  class Jekyll
    class FileHandler

      attr_reader :root, :files

      # Initializes a FileHandler for a given root directory
      # (for testing only: use a given array of filenames, +files+).
      def initialize(root, files = nil)
        @root = ::File.expand_path(root)
        @files = files || get_file_list
        @mimes = Rack::Mime::MIME_TYPES.map{|k,v| /#{k.gsub('.','\.')}$/i }
      end

      def empty?
        @files.empty?
      end

      def update
        @files = get_file_list
      end

      # Returns the full file system path of the file corresponding to
      # the given URL path, or +nil+ if no corresponding file exists.
      def get_filename(path)
        fullpath = ::File.join(@root, path)

        if @mimes.collect {|regex| fullpath =~ regex }.compact.empty?
          normalized = ::File.join(fullpath, "index.html")
        else
          normalized = fullpath
        end

        if @files.include?(normalized)
          filename = normalized
        else
          filename = nil
        end

        filename
      end

      private

      def get_file_list
        files = ::Dir[@root + "/**/*"]
        files.delete_if {|file| ::FileTest.directory?(file) }

        files
      end
    end
  end
end
