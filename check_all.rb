ids = [587, 595, 594, 574].each do |id|
  puts id
  # Attempt.search(created_at_gt: Time.zone.today).result.destroy_all
  system("bin/rake encode:attempts ID=#{id}")
  system("bin/rake all_checker:run ID=#{id}")
end
