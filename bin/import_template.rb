current_assignment_id = ARGV.first.to_i
json = ARGV.second.present? ? JSON[File.read(ARGV.second)] : JSON[STDIN.read]
json.map{ |j| j.merge!('current_assignment_id' => current_assignment_id) }
templates_json = ActionController::Parameters.new(data: json).permit(data: [:file1, :status, :user_id, :encode_code, :current_assignment_id, :assignment_id])
Template.import(templates_json['data'].map(&:to_hash))
