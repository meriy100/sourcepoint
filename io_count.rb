def io_count(arg)
  attempts = CurrentAssignment.find(arg).attempts
  attempt_count = attempts.count
  files = attempts.pluck(:file1)
  sum = files.map{|file| [file.scan(/printf/), file.scan("scanf"), file.scan("fgets"), file.scan("getchar")] }.flatten.count
  loc = files.map{|file| file.scan("\n") }.flatten.count
  ave = sum.to_f / attempt_count.to_f
  loc_ave = loc.to_f / attempt_count.to_f

  {
    id: arg,
    code: CurrentAssignment.find(arg).code,
    attempt_count: attempts.count,
    sum: sum,
    average: ave,
    loc_ave: loc_ave,
  }
end

if __FILE__ == $0
  if ARGV.first == '-c'
    code_mode = true
    ARGV.shift
  end
  ARGV.each do |arg|
    id = code_mode ? CurrentAssignment.where(code: arg).first.id : arg
    puts io_count(id).to_json
  end
end
