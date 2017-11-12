attempts = CurrentAssignment.last.attempts
max = attempts.count
idx = 0
as = attempts.reject do |attempt|
  idx += 1
  print "\r(#{idx}:#{max})".concat('#'.*(idx * 50 / max))
  status = false
  Tempfile.open do |temp|
    File.write temp, attempt.file1.encode('UTF-8', 'UTF-8')
    rh = RpcsHTTPS.new('126hahaha')
    res = rh.create_attempt(temp.path, 587)
    if m = res['location'].match(/(?<id>\d+\z)/)
      status = rh.get_attempt_status(m[:id])
    end
  end
  print " #{status}                           "
  status == 'checked'
end
binding.pry
print as.map(&:id)
puts
