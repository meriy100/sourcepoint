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
      code: '',
      assignment_ids: [75, 148, 216, 283, 355, 428],
    }, {
      id: 570,
      code: '',
      assignment_ids: [68, 142, 210, 279, 351],
    }, {
      id: 609,
      code: '',
      assignment_ids: [34, 104, 175],
    }, {
      id: 441,
      code: '05A1',
      assignment_ids: [22, 87, 163, 228, 295, 367],
    },
  ]

  has_many :templates
  has_many :attempts
end
