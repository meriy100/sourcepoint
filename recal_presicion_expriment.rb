def recall_precision(experiment)
  submission_lines = experiment.submissions.first.lines
  experiment_lines = experiment.experiment_lines
  true_lines = submission_lines.select { |l| experiment_lines.to_a.include?(l) }
  recall = (true_lines.length / experiment_lines.length.*(1.0))
  precision = (true_lines.length / submission_lines.length.*(1.0))
  [
    recall,
    precision
  ]
end

def show_sourcecode(experiment)
  lines = experiment.experiment_lines
  experiment.file1.split("\n").map.with_index(1) do |line, idx|
    color  = lines.map(&:number).include?(idx) ?  "\e[31m" : "\e[0m"
    puts color.concat("%2d " % idx).concat(line).concat("\e[0m")
  end
end

def experiment_rp(experiment)
    submission_lines = experiment.submissions.first.lines
    experiment_lines = experiment.experiment_lines
    true_lines = submission_lines.select { |l| experiment_lines.to_a.include?(l) }
    recall = (true_lines.length / experiment_lines.length.*(1.0))
    precision = (true_lines.length / submission_lines.length.*(1.0))
    submission_lines_group = experiment.submissions.first.lines.to_a.collection_map{|f,s| f.number+1 == s.number}
    true_lines_group = submission_lines_group.map { |ls| experiment_lines.map(&:number).&(ls.map(&:number)) }.compact.reject{|g|g.empty?}
    recall_of_group = (true_lines_group.flatten.length / experiment_lines.length.*(1.0))
    {
      experiment_id: experiment.id,
      submission_id: experiment.id,
      experiment_lines: experiment_lines.length,
      submission_lines: submission_lines_group.length,
      true_lines: true_lines_group.length,
      recall_of_group: recall_of_group,
      recall: recall,
      precision: precision,
      f: (2.0 / ( (1.0 / recall) + (1.0 / precision) ) ),
    }
end

if $0 == __FILE__
  if ARGV.first == 'check_mode'
    ARGV.shift
    ids_hash = { id: ARGV } if ARGV.present?
    puts ids_hash
    ids = ExperimentUser.where.not(start_at: nil).ids
    Experiment.where({experiment_user_id: ids}.merge(ids_hash)).each do |experiment|
      recall, precision = recall_precision(experiment)
      # next unless recall == 0 && precision == 0
      lines = experiment.experiment_lines

      print "ID "
      puts experiment.id
      print "user name "
      puts experiment.experiment_user.name
      print "status "
      puts experiment.status
      show_sourcecode(experiment)

      while puts("continue?: ") || $stdin.gets.match(/\d+/)
        lines = experiment.experiment_lines
        $_.scan(/\d+/).map(&:to_i).each do |number|
          unless lines.map(&:number).include?(number)
            experiment.experiment_lines.create!(number: number)
          else
            lines.find_by(number: number).destroy!
            lines = experiment.reload.experiment_lines
          end
        end
        show_sourcecode(experiment)
      end
    end
  elsif ARGV.first == 'show'
    ARGV.shift
    ARGV.each do |id|
      experiment = Experiment.find(id)
      puts experiment.submissions.first.id
      show_sourcecode(experiment)
    end
  elsif  ARGV.first == 'users'
    hash = ExperimentUser.where.not(start_at: nil).includes(experiments: :experiment_lines).map do |experiment_user|
      experiments_rp = experiment_user.experiments.reject{|e| e.experiment_lines.count.zero? || e.submissions.first.lines.count.zero? }.map do |experiment|
        experiment_rp(experiment)
      end
      recalls = experiments_rp.sum {|erp| erp[:recall]}
      precisions = experiments_rp.sum {|erp| erp[:precision]}
      fs = experiments_rp.sum {|erp| erp[:f]}
      {
        id: experiment_user.id,
        count: experiment_user.experiments.count,
        checked: experiment_user.experiments.any?{|e| e.status == 'checked' },
        recall: recalls./(experiment_user.experiments.count),
        precision: precisions./(experiment_user.experiments.count),
        f: fs./(experiment_user.experiments.count),
      }.merge(clear_time: (experiment_user.experiments.select{|e|e.status == 'checked'}.first&.created_at&.-(experiment_user.start_at)&./(60) ))
        .merge(experiment_user.csv_data.attributes)
    end
    if ARGV[1] == 'json'
      puts hash.to_json
    else
      puts hash.first.keys.join(', ')
      puts hash.map { |ob| ob.values.join(', ') }
    end

  elsif ARGV.first == 'diff_lines'
    hash = []
    ExperimentUser.where.not(start_at: nil).includes(experiments: :experiment_lines).map do |experiment_user|
      experiment_user.experiments.each_cons(2) do |first, second|
        i = 1
        lines = first.file1.split('').map {|c|  i += 1 if c == "\n"; [c, i] }
        lines_diffs = Diff::LCS.diff(first.file1, second.file1).flatten.map{|d| lines[d.position] || lines.last }.map(&:last).uniq
        hash.push({
          id: experiment_user.id,
          status: first.status,
          next_status: second.status,
          timediff: (second.created_at - first.created_at)./(60).round(3),
          diffs: first.submissions.first.lines.map(&:number).map{|n| [n, lines_diffs.include?(n)]},
        })
      end
    end

    hash.select!{|h|h[:diffs].present?}
    if ARGV[1] == 'json'
      puts hash.to_json
    else
      puts hash.first.keys.join(', ')
      puts hash.map { |ob| ob.values.join(', ') }
    end
  else
    ids = ExperimentUser.where.not(start_at: nil).ids
    hash = Experiment.where(experiment_user_id: ids).reject{|e|e.experiment_lines.count.zero? || e.submissions.first.lines.count.zero?}.map do |experiment|
      binding.pry if experiment.experiment_user.csv_data.blank?
      submission_lines = experiment.submissions.first.lines
      experiment_lines = experiment.experiment_lines
      true_lines = submission_lines.select { |l| experiment_lines.to_a.include?(l) }
      recall = (true_lines.length / experiment_lines.length.*(1.0))
      precision = (true_lines.length / submission_lines.length.*(1.0))
      submission_lines_group = experiment.submissions.first.lines.to_a.collection_map{|f,s| f.number+1 == s.number}
      true_lines_group = submission_lines_group.map { |ls| experiment_lines.map(&:number).&(ls.map(&:number)) }.compact.reject{|g|g.empty?}
      recall_of_group = (true_lines_group.flatten.length / experiment_lines.length.*(1.0))
      {
        experiment_id: experiment.id,
        submission_id: experiment.id,
        experiment_lines: experiment_lines.length,
        submission_lines: submission_lines_group.length,
        true_lines: true_lines_group.length,
        recall_of_group: recall_of_group,
        recall: recall,
        precision: precision,
        f: (2.0 / ( (1.0 / recall) + (1.0 / precision) ) ),
      }.merge(experiment.experiment_user.csv_data.attributes)
    end

    if ARGV.first == 'json'
      puts hash.to_json
    else
      puts hash.first.keys.join(', ')
      puts hash.map{|ob| ob.values.join(', ')  }
    end
  end
end


