namespace :all_checker do
  desc "all_checker"
  task run: :environment do
    before_submission_id = Submission.last.id
    current_assignment_id = ENV['ID']
    submissions_attrs = Template.where(status: ['internal_error', 'executed']).where(current_assignment_id: current_assignment_id).map do |template|
      common_column = %w{file1 messages status mark comment user_id}
      attrs = template.attributes.select{|key, _| common_column.include?(key) }.merge(assignment_id: template.current_assignment_id, template_id: template.id, submitted: Time.zone.now)
    end
    Submission.import(submissions_attrs)
    submissions = Submission.search(id_gt: before_submission_id).result
    submissions.each do |s|
      puts s.id
      SubmissionCreate.new(s.clone).run
    end
  end
end
