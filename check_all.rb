def main(ids = [], noneencode_reset=true)
  ids.each do |id|
    puts id
    unless (nonencode_reset || system("bin/rake encode:attempts ID=#{id}") ) && system("bin/rake all_checker:run ID=#{id}")
      puts "error : #{id}"
      exit
    end
  end
end

if __FILE__ == $0
  main(ARGV)
end
