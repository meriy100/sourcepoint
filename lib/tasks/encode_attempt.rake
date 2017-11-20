require 'benchmark'

namespace :encode do
  desc "set encode_code"
  task attempts: :environment do
    # Parallel.each(Attempt.where(assignment_id: 397), in_processes: 4) do |attempt|
    _427 = [74, 147, 215, 282, 354]
    _441 = [22, 87, 163, 228, 295, 367]
    _573 =  [74, 147, 215, 282, 354, 427]
    _595 = [30, 95, 171, 236, 303, 375, 449]
    _600 = [101, 242, 308, 380, 454]
    _609 = [99, 240, 312, 384, 458]
    id = ENV['ID']&.to_i || 441

    list = Attempt.where(current_assignment_id: id).map { |a| a.file1.lines.map { |s| s.match(%r{("[\w\W\s\S]*")}) } }.flatten.compact.group_by {|m| m[1]}.map {|s, data| [s, data.length]}.sort_by{|s, length| 0 - length}.map(&:first).map.with_index(0){|s,i| {string: s, encode_word: "@#{id}_#{i}"}}
    yaml = YAML.load_file(Rails.root.join('app', 'dictionaries', 'string_encode_word.yml')) || { string_encode_word: {} }

    if yaml[:string_encode_word].nil?
      yaml[:string_encode_word] = { id.to_s => list }
    else
      yaml[:string_encode_word][id.to_s] = list
    end
    File.open(Rails.root.join('app', 'dictionaries', 'string_encode_word.yml'), 'w') do |f|
      f.puts yaml.to_yaml
    end

    Parallel.each(Attempt.where(current_assignment_id: id), in_processes: 4) do |attempt|
    # Attempt.where(current_assignment_id: 574).each do |attempt|
    # Attempt.all.each do |attempt|
      print "#"
      begin
        encode_code = EncodingCode.new(attempt.file1, id).encode
        attempt.update!(encode_code: encode_code)
      rescue => e
        puts attempt.id
        raise e
      end
    end
    puts ""
  end

  task benchmark: :environment do
    benchmark = Benchmark.measure do
      Rake::Task['encode:attempts'].invoke
    end
    puts benchmark
  end
end
