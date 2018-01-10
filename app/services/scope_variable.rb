class ScopeVariable< EncodingCode
  def initialize(src, assignment_id, dictionary = nil)
    self.code_encoded ||= ""
    self.dictionary = dictionary || Dictionary.new(assignment_id)
    self.charlist = []
    self.code = src.encode('UTF-8', 'UTF-8').gsub(/\r[^$]/, "\n").gsub(/^(\s*)#\s*include\s*.*$/, '\1')
    remove_comment!
    self.headers = src.scan(/^\s*#\s*include\s*.*$/)
    self.assignment_id = assignment_id
    if code.lines.count != src.lines.count
      binding.pry if $0 == 'rails_console'
      raise LineCountUnsame
    end
    self.code = self.code.split("\n").map.with_index(1) do |line, idx|
      var_change(line, idx)
    end
      .join("\n")
    self.code = headers.join("\n").concat(self.code)
    self.code = string_encode_word_gsubs2(self.code, $string_encode_word[assignment_id.to_s].dup)
  end

  def string_encode_word_gsubs2(line, sews)
    return line if sews.blank?
    sew = sews.pop
    string_encode_word_gsubs2(
      line.gsub(sew[:encode_word], sew[:string].encode('UTF-8', 'UTF-8')),
      sews
    )
  end

end

