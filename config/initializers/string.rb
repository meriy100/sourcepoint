class String
  def to_tmp
    if block_given?
      Tempfile.create('sourcepoint-') do |tempfile|
        File.write(tempfile, self)
        yield(tempfile)
      end
    else
      Tempfile.create('sourcepoint-').tap { |tempfile| File.write(tempfile, self) }
    end
  end
end
