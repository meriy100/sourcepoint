def ids
  {
   632 => "1401",
   633 => "1402",
   634 => "1403",
   635 => "1404",
   636 => "1501",
   638 => "1502",
   639 => "1503",
   637 => "1504",
  }
end

def ids
  {
    632 => "12C1",
  }
end

data = Submission.where(assignment_id: ids.keys).includes(:lines).map do |submission|
  { user: submission.user_id, code: ids[submission.assignment_id], time: submission.created_at, status: submission.status, line_count: submission.lines.length }
end

puts JSON[data]

