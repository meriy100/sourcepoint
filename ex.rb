attempts_sliced = CurrentAssignment.find(594).attempts.pluck(:id).each_slice(4).to_a

attempts_sliced.each do |ids|
  binding.pry unless system("bin/rails r 'Attempt.where(id: #{ids}).each do |a| GC.start; SubmissionCreate.new(a.to_submission.tap(&:save!)).run end'")
end

