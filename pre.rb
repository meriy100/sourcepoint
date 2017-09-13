def average(ary)
  (ary.inject(:+) * 1.0 / ary.count)
end

values = Submission.where(assignment_id: ARGV.first.to_i).includes(:lines).map{|s| {user_id: s.user_id, line_count: s.lines.length}}.group_by{|i| i[:user_id]}.values
puts values.map { |user_data|
  {
    user_id: user_data.first[:user_id],
    line_count: average(user_data.map { |data| data[:line_count]})
  }
}.to_json

