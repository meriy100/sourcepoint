namespace :set_current_assignment_id do
  desc "set current_assignment_id"
  task run: :environment do
    current_assignment_id = 620
    assignment_ids = [47, 118, 187, 258, 330, 402, 475]
    Attempt.where(assignment_id: assignment_ids).each do |attempt|
      attempt.update!(current_assignment_id: current_assignment_id)
    end
  end
end

# 12A1
# assignment_ids = [120, 189, 260, 332, 404, 477]

# 12A2
# assignment_id = [121, 190, 261, 333, 405, 478]
#
# 12C1
# assignment_id = [54, 123, 192, 263, 335, 408, 481
