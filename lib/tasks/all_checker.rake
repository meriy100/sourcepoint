namespace :all_checker do
  desc "all_checker"
  task run: :environment do
    before_submission_id = Submission.last.id
    current_assignment_id = ENV['ID']
    templates = Template.where(status: ['internal_error', 'executed']).where(current_assignment_id: current_assignment_id, is_check: true)
    # templates = Template.where(status: ['internal_error', 'executed']).where(current_assignment_id: current_assignment_id)
    Submission.where(template_id: templates.map(&:id)).destroy_all
    submissions_attrs = templates.map do |template|
        common_column = %w{file1 messages status mark comment user_id}
        attrs = template.attributes.select{|key, _| common_column.include?(key) }.merge(assignment_id: template.current_assignment_id, template_id: template.id, submitted: Time.zone.now)
    end
    Submission.import(submissions_attrs)
    submissions = Submission.search(id_gt: before_submission_id).result
    max =  submissions.count
    $i = 0
    Parallel.each(submissions, in_processes: 2) do |s|
    # submissions.each do |s|
      $i = $i + 1
      puts "#{$i}/#{max}"
      puts s.id
      Parallel.each([s.clone], in_processes: 1) do |sc|
        SubmissionCreate.new(sc).run
      end
    end
    ActiveRecord::Base.clear_active_connections!

    data = Template.where(id: templates.map(&:id)).map do |template|
      submission_lines = template.submission.lines
      template_lines = template.template_lines
      true_lines = submission_lines.select { |l| template_lines.to_a.include?(l) }
      recall = (true_lines.length / submission_lines.length.*(1.0))
      precision = (true_lines.length / template_lines.length.*(1.0))
      {
        template_id: template.id,
        submission_id: template.id,
        template_lines: template_lines.length,
        submission_lines: submission_lines.length,
        true_lines: true_lines.length,
        recall: recall,
        precision: precision,
        f: (2.0 / ( (1.0 / recall) + (1.0 / precision) ) ),
      }
    end
    if Dir["data/#{current_assignment_id}"].empty?
      if Dir.mkdir("data/#{current_assignment_id}") != 0
        binding.pry
      end
    end

    File.open("./data/#{current_assignment_id}/#{Time.zone.now.strftime("%Y%m%d%H%M%S")}.json", 'w')  do |file|
      file.write data.to_json
    end
  end
end
# 641
