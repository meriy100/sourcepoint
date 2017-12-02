# [587, 595, 594, 574].each do |id|
#   binding.pry unless system("bin/rake encode:attempts ID=#{id}")
# end

# attempts_sliced = Attempt.where(current_assignment_id: [587, 595, 594, 574]).pluck(:id).each_slice(5).to_a
attempts_sliced = Attempt.where(current_assignment_id: [574]).pluck(:id).each_slice(5).to_a

attempts_sliced.each do |ids|
  binding.pry unless system("bin/rails r 'Attempt.where(id: #{ids}).each do |a| GC.start; SubmissionCreate.new(a.to_submission.tap(&:save!)).run end'")
end

