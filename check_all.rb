ids = [
      612,
].each do |id|

  puts id
  # Attempt.search(created_at_gt: Time.zone.today).result.destroy_all
  unless system("bin/rake encode:attempts ID=#{id}") && system("bin/rake all_checker:run ID=#{id}")
    puts "error : #{id}"
    exit
  end
end

