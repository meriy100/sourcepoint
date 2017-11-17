require 'json'
$string_encode_word = YAML.load_file(Rails.root.join('app', 'dictionaries', 'string_encode_word.yml'))[:string_encode_word]
class Dictionary < Hash
  attr_accessor :valiable_list, :assignment_id
  class EmptyHasList < StandardError; end

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
    self.code = src.gsub(/\r[^$]/, "\n").gsub(/^\s*#include .*$/, '')
    self.headers = src.scan(/^\s*#include .*$/)
    self.assignment_id = assignment_id
    if code.lines.count != src.lines.count
      binding.pry
    end
  end

  def headers_str
    headers.join("\n").concat("\n")
  end

  def for_while_if
    Tempfile.open do |f|
      File.write f, self.code
      path = '/Users/meriy100/Downloads/cparser/pycparser/examples'
      puts `cd #{path} && ruby deep_trace.rb #{f.path}`
    end
  end

  def recode(token_str)
    reverse_dic = self.dictionary.to_reverse
    token_str.split("\n").map do |line|
      line.split(' ').map do |token|
        reverse_dic[token].presence || token
      end.join(' ')
    end.join("\n")
  end

  def remove_comment
    code.gsub!(/(\/\/.*$|\/\*(.|\n)*\*\/)/, '') # TODO : gcc -なんとか
  end

  def main_norm
    return_norm
    code.gsub!(/int\s*main\s*\(\)/, "int main(void)")
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

  def decl_lines
    return @decl_lines if @decl_lines.present?
    json = nil
    Tempfile.open do |f|
      File.write f, code.encode('UTF-8', 'UTF-8')
      json = PyTool.pdggenerator(f)
    end
    @decl_lines = json['nodes'].select{|node| node['tag'] == 'Decl'}.map{|decl_node| decl_node['position']}.map{|position|position['line']}.compact.uniq
  rescue PyTool::ConvertError => e
    return []
  end

  def remove_decl(str)
    str.split("\n").map.with_index(1) { |line, idx| decl_lines.include?(idx) ?  '' : line }.join("\n")
  end

  def create_directory
    remove_comment
    main_norm
    remove_decl(code).split("\n").each do |line|
      # TODO : 数字はエンコーディングするのかどうか
      token_set(line)
    end
  end

  def token_set(line)
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
      .gsub(/\//, ' / ')
      .gsub(/%/, ' % ')
      .gsub(/ (?<num>\d+(\.\d+)?) /, ' \k<num> ')
      .gsub(/FP/, 'fp')
      .split(" ").map do |word|
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
    remove_comment
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
