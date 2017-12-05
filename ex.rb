# [587, 595, 594, 574].each do |id|
#   binding.pry unless system("bin/rake encode:attempts ID=#{id}")
# end

# attempts_sliced = Attempt.where(current_assignment_id: [587, 595, 594, 574]).pluck(:id).each_slice(5).to_a
LENGTH = 90
START_TIME = Time.zone.now
attempts_sliced = Attempt.where(current_assignment_id: [595]).pluck(:id).each_slice(5).to_a
# Tempfile.create('sourcepoint-') do |tmp|
#   puts "tail -f #{tmp.path}"
#   max = attempts_sliced.count * 1.0
#   Parallel.each_with_index(attempts_sliced, in_processes: 2) do |ids, idx|
#     File.open(tmp.path, "a") do |f|
#     f.print "\r".concat("#" * (idx * LENGTH / max) .to_i).concat(" " * (LENGTH - idx * LENGTH / max).to_i).concat("|(#{idx}/#{max})")
#     end
#     binding.pry unless system("bin/rails r 'Attempt.where(id: #{ids}).each do |a| GC.start; SubmissionCreate.new(a.to_submission, same_search: false).pre_run end'")
#   end
# end

attempts = Attempt.where(current_assignment_id: [595])
max = attempts.count * 1.0

def least_minutes(max, idx)
  (Time.zone.now - START_TIME)./(idx).*(max - idx)./(60).to_i.to_s
rescue FloatDomainError => _
  "∞"
end

Parallel.each_with_index(attempts, in_processes: 2) do |attempt, idx|

  print "\r".concat("#" * (idx * LENGTH / max) .to_i).concat(" " * (LENGTH - idx * LENGTH / max).to_i).concat("|(#{idx}/#{max}) : #{least_minutes(max, idx)}m        ")
  GC.start;
  _, stderr, status = Open3.capture3('bin/rails', 'r', %{SubmissionCreate.new(Attempt.find(#{attempt.id}).to_submission, same_search: false).pre_run})
  unless status.success?
    STDERR.puts stderr
    exit
  end
end

