class Dictionary < Hash
  $string_encode_word = YAML.load_file(Rails.root.join('app', 'dictionaries', 'string_encode_word.yml'))[:string_encode_word]
  attr_accessor :valiable_list, :assignment_id
  class EmptyHasList < StandardError; end
  class LineCountUnsame < StandardError; end

  RESERVED_WORDS = %w{
      void char short int long float double auto static const signed unsigned extern volatile register return goto if else switch case default break for while do continue typedef struct enum union
      sizeof #include printf scanf fgets getchar FILE fopen fclose EOF exit stdio math string stdlib malloc main EOF NULL free strcpy strcat stdin define h pow @s $c fp fwrite fseek SEEK_SET clean_string fprintf stderr
      stdlib sqrt abs
    }.freeze

  HASH_LIST = ('A'..'Z').to_a.concat(('a'..'z').to_a).combination(2).map{|a, b|"#{a}#{b}"}.shuffle(random: Random.new(100)).freeze

  def initialize(assignment_id)
    self.assignment_id = assignment_id
    hash_list_init
    reserve_word
    $string_encode_word[assignment_id.to_s].each do |list|
      reserve_word_set_string(list[:encode_word], list[:string])
    end
    buf = @hash_list.each_slice(40).to_a
    @func_list = buf.pop
    @var_list = buf
  end

  def hash_list_init
    @hash_list = HASH_LIST.dup
  end

  def set(word, type=nil)
    unless include?(word)
      case type
      when 'FuncDef', 'FuncDecl'
        self[word] = { encode: next_func_name_token, word: word, valiable: true, func: true }
      else
        self[word] = { encode: next_var_name_token, word: word, valiable: true }
      end
      self[word][:encode]
    end
  end

  def valiable_list
    self.select { |_, value| value[:valiable] }
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
    self[word] = { encode: tail_encode, word: word, string: string }
  end

  def reserve_word_set(word)
    self[word] = { encode: tail_encode, word: word }
  end


  def reserve_word
    RESERVED_WORDS.each do |word|
      reserve_word_set(word)
    end
  end

  def next_encode
    raise EmptyHasList if @hash_list.blank?
    @hash_list.shift
  end

  def next_func_name_token
    raise EmptyHasList if @func_list.blank?
    @func_list.shift
  end

  def next_var_name_token(order = 0)
    binding.pry if @var_list[order].blank?
    raise EmptyHasList if @var_list[order].blank?
    @var_list[order].shift
  end

  def tail_encode
    raise EmptyHasList if @hash_list.blank?
    @hash_list.pop
  end
end

