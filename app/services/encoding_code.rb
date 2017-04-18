class Dictionary < Hash
  class EmptyHasList < StandardError; end
  def initialize
    @hash_list = ("A".."Z").to_a.concat(("a".."z").to_a) # TODO : 二桁にする (16進数にすればいいかも)
    reserve_word
  end

  def set(word)
    unless include?(word)
      self[word] = { encode: next_encode, word: word }
      self[word][:encode]
    end
  end

  private

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
      "include",
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
    ].each do |word|
      set(word)
    end
  end

  def next_encode
    raise EmptyHasList if @hash_list.blank?
    "$#{@hash_list.pop}"
  end
end

class EncodingCode
  attr_accessor :code, :code_encoded, :dictionary

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
  ].freeze

  def initialize(src, dictionary = Dictionary.new)
    self.code_encoded ||= ""
    self.dictionary = dictionary

    self.code = src
  end

  def remove_comment
    code.gsub!(/(^\/\/.*$|\/\*(.|\n)*\*\/)/, '')
  end

  def num?(word)
    word =~ /\A-?\d+(.\d+)?\Z/
  end

  def encode
    remove_comment
    code.each_line do |line|
      # TODO : 数字はエンコーディングするのかどうか
      words = line
        .gsub(%r{("[\w\W\s\S]*")}, " @s ")
        .gsub(/(?<first>[\(|\)|\{|\}|\[|\]|;|:])/, ' \k<first> ')
        .gsub(/'\w'/, ' $c ')
        .gsub(/(?<prev>[^=!<>])=(?<next>[^=])/, '\k<prev> = \k<next>')
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
        .gsub(/,/, ' , ')
        .gsub(/\./, ' . ')
        .gsub(/(?<num>\d+)/, ' \k<num> ')
        .gsub(/=/, ' = ')
        .gsub(/\+/, ' + ')
        .gsub(/-/, ' - ')
        .gsub(/\*/, ' * ')
        .gsub(/\//, ' / ')
        .gsub(/%/, ' % ')
        .gsub(/&/, ' & ')
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
      code_encoded.concat(words.join(" "))
      code_encoded.concat(' ')
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
