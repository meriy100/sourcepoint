require 'benchmark'

namespace :encode do
  desc "set encode_code"
  task attempts: :environment do
    # Parallel.each(Attempt.limit(1000), in_processes: 2) do |attempt|
    Attempt.all.each do |attempt|
      encode_code = EncodingCode.new(attempt.file1).encode
      attempt.update!(encode_code: encode_code)
    end
  end

  task benchmark: :environment do
    benchmark = Benchmark.measure do
      Rake::Task['encode:attempts'].invoke
    end
    puts benchmark
  end
end
