class Dictionary < Hash
  attr_accessor :valiable_list
  class EmptyHasList < StandardError; end
  def initialize
    @hash_list = ("A".."Z").to_a.concat(("a".."z").to_a).combination(2).map{|a, b|"#{a}#{b}"}.shuffle(random: Random.new(100))
    reserve_word
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

  private

  def for_while_if
    if m = line.match(/for.*(\n|){((.|\n)*)}/)
      if m[2].lines.count < 1
      end
    end
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
      "'\\0'",
      "'\\n'",
    ].each do |word|
      reserve_word_set(word)
    end
  end

  def next_encode
    raise EmptyHasList if @hash_list.blank?
    "#{@hash_list.pop}"
  end
end

class SplitFunction
  attr_accessor :code
  def initialize(code)
    self.code = code
  end

end

class EncodingCode
  attr_accessor :code, :code_encoded, :dictionary, :charlist

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
    "&",
    ">",
    "<",
    "!",
    "@s",
  ].freeze

  def initialize(src, dictionary = Dictionary.new)
    self.code_encoded ||= ""
    self.dictionary = dictionary
    self.charlist = []

    self.code = src
  end

  def remove_comment
    code.gsub!(/(\/\/.*$|\/\*(.|\n)*\*\/)/, '')
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

  def create_directory
    remove_comment
    main_norm
    code.split("\n").each do |line|
      # TODO : 数字はエンコーディングするのかどうか
      words = line
        .gsub(%r{("[\w\W\s\S]*")}, " @s ")
        .gsub(/(?<first>[\(\)\{\}\[\];:])/, ' \k<first> ')
        .gsub(/'\w'/, ' $c ')
        .gsub(/(?<prev>[^=!<>+-])=(?<next>[^=])/, '\k<prev> = \k<next>')
        .gsub(/(?<prev>[^+])\+(?<next>[^+=])/, '\k<prev> + \k<next>')
        .gsub(/(?<prev>[^-])-(?<next>[^-=])/, '\k<prev> - \k<next>')
        .gsub(/(?<prev>[^&])&(?<next>[^&])/, '\k<prev> & \k<next>')
        .gsub(/<(?<next>[^=])/, ' < \k<next>')
        .gsub(/>(?<next>[^=])/, ' > \k<next>')
        .gsub(/!(?<next>[^=])/, ' ! \k<next>')
        .gsub(/==/, " == ")
        .gsub(/<=/, " <= ")
        .gsub(/>=/, " >= ")
        .gsub(/!=/, " != ")
        .gsub(/&&/, " && ")
        .gsub(/\|\|/, " || ")
        .gsub(/\+\+/, " ++ ")
        .gsub(/--/, " -- ")
        .gsub(/\+=/, " += ")
        .gsub(/-=/, " -- ")
        .gsub(/,/, ' , ')
        .gsub(/\./, ' . ')
        .gsub(/ (?<num>\d+) /, ' \k<num> ')
        .gsub(/\*/, ' * ')
        .gsub(/\//, ' / ')
        .gsub(/%/, ' % ')
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
  end

  def encode
    create_directory
    remove_comment
    main_norm
    code.each_line.with_index(1) do |line, idx|
      # TODO : 数字はエンコーディングするのかどうか
      words = line
        .gsub(%r{("[\w\W\s\S]*")}, " @s ")
        .gsub(/(?<first>[\(\)\{\}\[\];:])/, ' \k<first> ')
        .gsub(/'\w'/, ' $c ')
        .gsub(/(?<prev>[^=!<>+-])=(?<next>[^=])/, '\k<prev> = \k<next>')
        .gsub(/(?<prev>[^+])\+(?<next>[^+=])/, '\k<prev> + \k<next>')
        .gsub(/(?<prev>[^-])-(?<next>[^-=])/, '\k<prev> - \k<next>')
        .gsub(/(?<prev>[^&])&(?<next>[^&])/, '\k<prev> & \k<next>')
        .gsub(/<(?<next>[^=])/, ' < \k<next>')
        .gsub(/>(?<next>[^=])/, ' > \k<next>')
        .gsub(/!(?<next>[^=])/, ' ! \k<next>')
        .gsub(/==/, " == ")
        .gsub(/<=/, " <= ")
        .gsub(/>=/, " >= ")
        .gsub(/!=/, " != ")
        .gsub(/&&/, " && ")
        .gsub(/\|\|/, " || ")
        .gsub(/\+\+/, " ++ ")
        .gsub(/--/, " -- ")
        .gsub(/\+=/, " += ")
        .gsub(/-=/, " -- ")
        .gsub(/,/, ' , ')
        .gsub(/\./, ' . ')
        .gsub(/ (?<num>\d+) /, ' \k<num> ')
        .gsub(/\*/, ' * ')
        .gsub(/\//, ' / ')
        .gsub(/%/, ' % ')
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
      encode_line = words.join(" ").concat(' ')
      encode_line.gsub!(/ +/, ' ')
      encode_line.gsub!(/\A +/, '')
      code_encoded.concat(encode_line)
      charlist.concat(encode_line.split('').map { |char| [idx, char] })
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
