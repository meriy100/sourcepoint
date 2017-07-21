a1512A1 = 477
a1512B1 = 479
a1512C1 = 480
data = Attempt.where(assignment_id: a1512A1).map do |attempt|
  { status: attempt.status, time: attempt.created_at, user: attempt.user_id, code: "1512A1" }
end
data.concat(
  Attempt.where(assignment_id: a1512B1).map do |attempt|
    { status: attempt.status, time: attempt.created_at, user: attempt.user_id, code: "1512B1" }
  end
)
data.concat(
  Attempt.where(assignment_id: a1512C1).map do |attempt|
    { status: attempt.status, time: attempt.created_at, user: attempt.user_id, code: "1512C1" }
  end
)
puts data.to_json

