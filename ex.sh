while read -r line
do
  echo "$line" |
  bin/rails r  'puts Attempt.where(current_assignment_id: gets.to_i).pluck(:id)' |
  xargs -P 5 bin/rails r  'SubmissionCreate.new(Attempt.find(gets.to_i).to_submission, same_search: false).pre_run'
done
