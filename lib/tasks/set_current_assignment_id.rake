namespace :set_current_assignment_id do
  desc "set current_assignment_id"
  task run: :environment do

    _573 = [74, 147, 215, 282, 354, 427]
    current_assignment_id = 573
    assignment_ids = _573
    Attempt.where(assignment_id: assignment_ids).each do |attempt|
      attempt.update!(current_assignment_id: current_assignment_id)
    end

    # _573 = [30, 95, 171, 236, 303, 375, 449]
    # _609 = [99, 240, 312, 384, 458]
    # _600 = [101, 242, 308, 380, 454]
    # current_assignment_id = 600

    # current_assignment_id = 441
    # assignment_ids = [22, 87, 163, 228, 295, 367]
    # Attempt.where(assignment_id: assignment_ids).each do |attempt|
    #   attempt.update!(current_assignment_id: current_assignment_id)
    # end

    # current_assignment_id = 427
    # assignment_ids = [74, 147, 215, 282, 354]
    # Attempt.where(assignment_id: assignment_ids).each do |attempt|
    #   attempt.update!(current_assignment_id: current_assignment_id)
    # end

    #
    #
    # current_assignment_id = 628
    # assignment_ids = [336, 409, 482]
    # Attempt.where(assignment_id: assignment_ids).each do |attempt|
    #   attempt.update!(current_assignment_id: current_assignment_id)
    # end
    #
    # current_assignment_id = 636
    # assignment_ids = [344, 417, 490]
    # Attempt.where(assignment_id: assignment_ids).each do |attempt|
    #   attempt.update!(current_assignment_id: current_assignment_id)
    # end
    #
    # current_assignment_id = 637
    # assignment_ids = [345, 418, 491]
    # Attempt.where(assignment_id: assignment_ids).each do |attempt|
    #   attempt.update!(current_assignment_id: current_assignment_id)
    # end
    #
    # current_assignment_id = 638
    # assignment_ids = [346, 419, 492]
    # Attempt.where(assignment_id: assignment_ids).each do |attempt|
    #   attempt.update!(current_assignment_id: current_assignment_id)
    # end
    #
    # current_assignment_id = 639
    # assignment_ids = [347, 420, 493]
    # Attempt.where(assignment_id: assignment_ids).each do |attempt|
    #   attempt.update!(current_assignment_id: current_assignment_id)
    # end
  end
end

