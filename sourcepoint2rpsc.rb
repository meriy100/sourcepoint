def counting(user_ids, results = {})
  return results unless user_id = user_ids.pop
  if results[user_id].blank?
    results[user_id] = { count: 1, id: user_id }
  else
    results[user_id][:count] += 1
  end
  counting(user_ids, results)
end

json = JSON[File.read('../pre.json')]
puts json.map { |user, times|
  user_ids = times.flat_map do |t|
    time = Time.zone.parse(t) + 9.hour
    Submission.search(created_at_gt: time - 4.second, created_at_lteq: time + 4.second).result.pluck(:user_id)
  end
  {
    user: user,
    sourcepoint: counting(user_ids).values.max_by{|v|v[:count]}
  }
}.to_json
