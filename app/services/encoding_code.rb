require 'json'
$string_encode_word = YAML.load_file(Rails.root.join('app', 'dictionaries', 'string_encode_word.yml'))[:string_encode_word]
class Dictionary < Hash
  attr_accessor :valiable_list, :assignment_id
  class EmptyHasList < StandardError; end
  class LineCountUnsame < StandardError; end

  def initialize(assignment_id)
    @hash_list = ("A".."Z").to_a.concat(("a".."z").to_a).combination(2).map{|a, b|"#{a}#{b}"}.shuffle(random: Random.new(100))
    self.assignment_id = assignment_id
    reserve_word
    $string_encode_word[assignment_id.to_s].each do |list|
      reserve_word_set_string(list[:encode_word], list[:string])
    end
  end

  def set(word)
    unless include?(word)
      self[word] = { encode: next_encode, word: word, valiable: true }
      self[word][:encode]
    end
  end

  def valiable_list
    self.select do |word, value|
      value[:valiable]
    end
  end

  def valiable_order_changes
    code_list = valiable_list.map { |_, value| value[:encode] }
    valiable_list.keys.permutation(valiable_list.count).map do |words|
      dup_dic = self.dup
      words.zip(code_list).map do |word, code|
        dup_dic[word] = { encode: code, word: word, valiable: true }
      end
      dup_dic
    end
  end

  def to_reverse
    self.values.each_with_object({}) { |s, rd| rd[s[:encode]] = (s[:string] || s[:word]) }
  end

  private

  def reserve_word_set_string(word, string)
    self[word] = { encode: next_encode, word: word, string: string }
  end

  def reserve_word_set(word)
    self[word] = { encode: next_encode, word: word }
  end

  def reserve_word
    [
      "void",
      "char",
      "short",
      "int",
      "long",
      "float",
      "double",
      "auto",
      "static",
      "const",
      "signed",
      "unsigned",
      "extern",
      "volatile",
      "register",
      "return",
      "goto",
      "if",
      "else",
      "switch",
      "case",
      "default",
      "break",
      "for",
      "while",
      "do",
      "continue",
      "typedef",
      "struct",
      "enum",
      "union",
      "sizeof",
      "#include",
      "printf",
      "scanf",
      "fgets",
      "getchar",
      "FILE",
      "fopen",
      "fclose",
      "EOF",
      "exit",
      "stdio",
      "math",
      "string",
      "stdlib",
      "malloc",
      "main",
      "EOF",
      "NULL",
      "free",
      "strcpy",
      "strcat",
      "stdin",
      "#define",
      "h",
      "pow",
      "@s",
      "$c",
      "fp",
      "fwrite",
      "fseek",
      "SEEK_SET",
      "clean_string",
      "fprintf",
      "stderr",
      'stdlib',
      "'\\0'",
      "'\\n'",
      'sqrt',
      'abs',
    ]
    .each do |word|
      reserve_word_set(word)
    end
  end

  def next_encode
    raise EmptyHasList if @hash_list.blank?
    "#{@hash_list.pop}"
    # "#{@hash_list.last}"
  end

  def tail_encode
    raise EmptyHasList if @hash_list.blank?
    "#{@hash_list.shift}"
  end
end

class CharSet < Array
  def number
    self.first
  end

  def number=(other)
    self[0] = other
  end
end

class EncodingCode
  attr_accessor :code, :code_encoded, :dictionary, :charlist, :headers, :assignment_id

  EXPECT_CHARS = [
    "{",
    "}",
    "[",
    "]",
    "(",
    ")",
    ";",
    "\n",
    ":",
    "==",
    "||",
    "&&",
    "%",
    "!=",
    "<=",
    ">=",
    "=",
    ",",
    ".",
    "+",
    "*",
    "-",
    "++",
    "--",
    "+=",
    "-=",
    "*=",
    "&",
    ">",
    "<",
    "!",
    "^",
  ].freeze

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
  end

  def headers_str
    headers.join("\n").concat("\n")
  end

  def ext
    return @ext unless @ext.nil?
    code.to_tmp do |tmp|
      @ext = PyTool.pycparser(tmp)['ext']
    end
  rescue PyTool::ConvertError => e
    return []
  end

  def vars
    return @vars if @vars.present?
    @vars ||= PyTool::ExtVars.main(ext).flat_map(&:to_sets).map{|s| { name: s.name, p: s.p, token: s.token }}
      .reject{|v|v.token.nil?}
      .reject{|v|v.name == 'main'}
  rescue PyTool::ConvertError => e
    return []
  end

  def var_change(line, idx)
    this_lines_vars = vars.select{|var| var[:p].first == idx}.sort_by{|v|v.p.last}
    result = split_token(line)
    cut_num = 0
    this_lines_vars.each do |var|
      # position = var[:p].last - 1 - cut_num
      # range = position + var.name.length
      # unless result[position...range] == var.name
      #   binding.pry if $0 == 'rails_console'
      #   raise PyTool::ConvertError
      # end
      # result.gsub!(/^(.{#{position}})(#{var.name})/, "\\1#{var.token}")
      # cut_num += var.name.length - var.token.length
      #
      result.gsub!(/(^|\s)#{var.name}($|\s)/, " #{var.token} ")
    end
    result
  end

  def recode(token_str)
    reverse_dic = self.dictionary.to_reverse
    token_str.split("\n").map do |line|
      line.split(' ').map do |token|
        reverse_dic[token].presence || token
      end.join(' ')
    end.join("\n")
  end

  def remove_comment!
    code.gsub!(%r{(/\*[\s\S]*?\*/|//.*)}) do |m|
      m.split('').select{|c|c=="\n"}.join
    end
  end

  def main_norm
    return_norm
    code.gsub!(/int\s*main\s*\(\s*\)/, "int main(void)")
  end

  def return_norm
    code.gsub!(/return\s*0\s*/, "return(0)")
  end

  def num?(word)
    word =~ /\A-?\d+(.\d+)?\Z/
  end

  def string_encode_word_gsubs(line, sews)
    return line if sews.blank?
    sew = sews.pop
    string_encode_word_gsubs(
      line.gsub(sew[:string].encode('UTF-8', 'UTF-8'), sew[:encode_word]),
      sews
    )
  end

  def decl_search(ext)
    result = []
    case ext
    when Array
      result.concat(
        ext.flat_map do |e|
          decl_search(e)
        end
      )
    when Hash
      if ext._nodetype == 'Decl'
        [PyTool::COORD_PARSE.(ext.coord).first]
      else
        result.concat(
          ext.values.flat_map { |e| decl_search(e) }
        )
      end
    else
      result
    end
  end

  def decl_lines
    return @decl_lines unless @decl_lines.nil?
    @decl_lines = decl_search(ext)
  # rescue PyTool::ConvertError => e
  #   return @decl_lines = []
  end

  def remove_decl(str)
    str.split("\n").map.with_index(1) { |line, idx| decl_lines.include?(idx) ?  '' : line }.join("\n")
  end

  def create_directory
    main_norm
    remove_decl(code).split("\n").each do |line|
      # TODO : 数字はエンコーディングするのかどうか
      token_set(line)
    end
  end

  def split_token(line)
    string_encode_word_gsubs(line.encode('UTF-8', 'UTF-8'), $string_encode_word[assignment_id.to_s].dup)
      .gsub(%r{("[\w\W\s\S]*")}, " @s ")
      .gsub(/(?<first>[\(\)\{\}\[\];:])/, ' \k<first> ')
      .gsub(/'\w'/, ' $c ')
      .gsub(/(?<prev>[^\*=!<>+-])=(?<next>[^=])/, '\k<prev> = \k<next>')
      .gsub(/(?<prev>[^+])\+(?<next>[^+=])/, '\k<prev> + \k<next>')
      .gsub(/(?<prev>[^*])\*(?<next>[^*=])/, '\k<prev> * \k<next>')
      .gsub(/(?<prev>[^-])-(?<next>[^-=])/, '\k<prev> - \k<next>')
      .gsub(/(?<prev>[^&])&(?<next>[^&])/, '\k<prev> & \k<next>')
      .gsub(/<</, ' << ')
      .gsub(/<(?<next>[^=])/, ' < \k<next>')
      .gsub(/>(?<next>[^=])/, ' > \k<next>')
      .gsub(/!(?<next>[^=])/, ' ! \k<next>')
      .gsub(/\^/, " ^ ")
      .gsub(/==/, " == ")
      .gsub(/<=/, " <= ")
      .gsub(/>=/, " >= ")
      .gsub(/!=/, " != ")
      .gsub(/&&/, " && ")
      .gsub(/\|\|/, " || ")
      .gsub(/\+\+/, " ++ ")
      .gsub(/--/, " -- ")
      .gsub(/\+=/, " += ")
      .gsub(/\*=/, " *= ")
      .gsub(/-=/, " -- ")
      .gsub(/,/, ' , ')
      .gsub(/(?<prev>.)\.(?<next>[a-zA-Z])/, '\k<prev> . \k<next>')
      .gsub(/\//, ' / ')
      .gsub(/%/, ' % ')
      .gsub(/ (?<num>\d+(\.\d+)?) /, ' \k<num> ')
      .gsub(/FP/, 'fp')
  end

  def token_set(line)
    split_token(line).split(" ").map do |word|
      if EXPECT_CHARS.include? word
        word
      elsif num?(word)
        word
      elsif dictionary.include? word
        dictionary[word][:encode]
      else
        dictionary.set(word)
      end
    end
  end

  def encode
    return code_encoded if charlist.present?
    create_directory
    main_norm
    code.each_line.with_index(1) do |line, idx|
      # TODO : 数字はエンコーディングするのかどうか
      words = token_set(line)
      encode_line = words.join(" ").concat(' ')
      encode_line.gsub!(/ +/, ' ')
      encode_line.gsub!(/\A +/, '')
      code_encoded.concat(encode_line)
      charlist.concat(encode_line.split('').map { |char| CharSet.new([idx, char]) })
    end

    code_encoded
  end
end

def main(file_path)
  encode_code = EncodingCode.new(File.read(file_path))

  print encode_code.encode
end

if __FILE__ == $0
  main(ARGV.first)
end
