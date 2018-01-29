def check_all(id, nonencode_reset=false)
  puts id
  if YAML.load_file(Rails.root.join('app', 'dictionaries', 'string_encode_word.yml'))[:string_encode_word]["#{id}"].blank?
    system("bin/rake encode:attempts ID=#{id}")
  end
  unless system("bin/rake all_checker:run ID=#{id} NOSECONDS=1   ")
    puts "error : #{id}"
    exit
  end
end

if __FILE__ == $0
  if ARGV.first == '-c'
    code_mode = true
    ARGV.shift
  end
  ARGV.each do |arg|
    id = code_mode ? CurrentAssignment.where(code: arg).first.id : arg
    check_all(id)
  end
end
