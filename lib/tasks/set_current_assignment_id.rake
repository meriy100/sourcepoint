namespace :set_current_assignment_id do
  desc "set current_assignment_id"
  task run: :environment do
    current_assignment_id = 612
    assignment_ids = [320, 392, 466]
    Attempt.where(assignment_id: assignment_ids).each do |attempt|
      attempt.update!(current_assignment_id: current_assignment_id)
    end
  end
end
