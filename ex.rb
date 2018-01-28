LENGTH = 90
START_TIME = Time.zone.now

ids = CurrentAssignment.where(code: ARGV).map(&:id)

ids.map(&:to_i).each do |assignment_id|
  attempts = Attempt.where(current_assignment_id: assignment_id)
  max = attempts.count * 1.0

  CurrentAssignment.find(assignment_id).attempts.sort_by(&:encode_code).each_cons(2) do |first, second|
    first.destroy if first.encode_code == second.encode_code
  end

  def least_minutes(max, idx)
    (Time.zone.now - START_TIME)./(idx).*(max - idx)./(60).to_i.to_s
  rescue FloatDomainError => _
    "∞"
  end

  Parallel.each_with_index(attempts, in_processes: 8) do |attempt, idx|

    print "\r".concat("#" * (idx * LENGTH / max) .to_i).concat(" " * (LENGTH - idx * LENGTH / max).to_i).concat("|(#{idx}/#{max}) : #{least_minutes(max, idx)}m        ")
    GC.start;
    _, stderr, status = Open3.capture3('bin/rails', 'r', %{SubmissionCreate.new(Attempt.find(#{attempt.id}).to_submission, same_search: false).pre_run})
    unless status.success?
      STDERR.puts "*"* 10
      STDERR.puts stderr
      Open3.capture3('mail', '-s', 'sourcepoint', '-r', 'ttattataa@gmail.com', 'ttattataa@gmail.com', stdin_data: "attempt_id: #{attempt.id}\n#####################\n\n#{stderr}")
      exit
    end
  end


  Open3.capture3('mail', '-s', 'sourcepoint', '-r', 'ttattataa@gmail.com', 'ttattataa@gmail.com', stdin_data: "exおわったよ")

  CurrentAssignment.find(assignment_id).attempts.sort_by(&:encode_code).each_cons(2) do |first, second|
    first.destroy if first.encode_code == second.encode_code
  end
end
