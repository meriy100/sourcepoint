require 'benchmark'

namespace :encode do
  desc "set encode_code"
  task attempts: :environment do
    Parallel.each(Attempt.where(assignment_id: 397), in_processes: 4) do |attempt|
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
