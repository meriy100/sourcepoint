require 'benchmark'

namespace :encode do
  desc "set encode_code"
  task attempts: :environment do
    # Parallel.each(Attempt.where(assignment_id: 397), in_processes: 4) do |attempt|
    _427 = [74, 147, 215, 282, 354]
    _441 = [22, 87, 163, 228, 295, 367]
    _595 = [30, 95, 171, 236, 303, 375, 449]
    Parallel.each(Attempt.where(assignment_id: _595), in_processes: 4) do |attempt|
    # Attempt.all.each do |attempt|
      print "#"
      encode_code = EncodingCode.new(attempt.file1).encode
      attempt.update!(encode_code: encode_code)
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
