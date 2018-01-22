class CurrentAssignment < ActiveHash::Base
  include ActiveHash::Associations
  self.data = [
    {
      id: 594,
      code: '06A2',
      assignment_ids: [29, 94, 170, 235, 302, 374, 448],
    }, {
      id: 595,
      code: '06B1',
      assignment_ids: [30, 95, 171, 236, 303, 375, 449],
    }, {
      id: 600,
      code: '07A1',
      assignment_ids: [101, 242, 308, 380, 454],
    }, {
      id: 573,
      code: '02B1',
      assignment_ids: [74, 147, 215, 282, 354, 427],
    }, {
      id: 623,
      code: '12A1',
      assignment_ids: [332, 404, 477],
    }, {
      id: 632,
      code: '1401',
      assignment_ids: [340, 413, 486],
    }, {
      id: 574,
      code: '02C1',
      assignment_ids: [75, 148, 216, 283, 355, 428],
    }, {
      id: 570,
      code: '01B1',
      assignment_ids: [4, 68, 142, 210, 279, 351, 424],
    }, {
      id: 609,
      code: '',
      assignment_ids: [34, 104, 175],
    }, {
      id: 587,
      code: '05A1',
      assignment_ids: [22, 87, 163, 228, 295, 367],
    }, {
      id: 572,
      code: '01C2',
      assignment_ids: [6, 70, 144, 212, 281, 353, 426],
    }, {
      id: 576,
      code: '03B1',
      assignment_ids: [13, 77, 150, 218, 285, 357, 430],
    }, {
      id: 577,
      code: '03C1',
      assignment_ids: [14, 78, 151, 219, 286, 358, 431],
    }, {
      id: 581,
      code: '04A1',
      assignment_ids: [17, 81, 157, 222, 289, 361, 435],
    }, {
      id: 612,
      code: '09B1',
      assignment_ids: [37, 107, 178, 248, 320, 392, 466],
    }, {
      id: 588,
      code: '05B1',
      assignment_ids: [24, 89, 165, 230, 297, 369, 442],
    }, {
      id: 578,
      code: '03C2',
      assignment_ids: [79, 152, 220, 287, 359, 432],
    },
  ]

  has_many :templates
  has_many :attempts


  def set_current_assignment_id
    Attempt.where(assignment_id: assignment_ids).update_all(current_assignment_id: id)
  end

end
