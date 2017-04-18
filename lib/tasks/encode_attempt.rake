namespace :encode do
  desc "set encode_code"
  task attempts: :environment do
    ActiveRecord::Base.transaction do
      Attempt.all.limit(10).each do |attempt|
        encode_code = EncodingCode.new(attempt.file1).encode
        attempt.update!(encode_code: encode_code)
      end
    end
  end
end
