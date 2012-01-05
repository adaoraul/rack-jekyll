class String
  if RUBY_VERSION < "1.9"
    def bytesize
      size
    end
  end
end
