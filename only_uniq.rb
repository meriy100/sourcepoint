def only_uniq(id)
  attempts = CurrentAssignment.find(id).attempts
  uniq_ids = attempts.to_a.uniq(&:file1).map(&:id)
  duppplicaitons = attempts.reject{ |a| uniq_ids.include?(a.id) }
  if attempts.count - attempts.uniq(&:file1).count == duppplicaitons.count
    STDOUT.puts duppplicaitons.count
    Attempt.where(id:duppplicaitons.map(&:id)).destroy_all
  end
end

if __FILE__ == $0
  ARGV.each do |arg|
    only_uniq(arg)
  end
end
