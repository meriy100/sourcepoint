require 'rails_helper'

RSpec.describe SubmissionCreate do
  describe '#line_to_diffs' do
    let(:actual_code) {
      'TY Jm ( BE FR ) ; BE di ( Su ) { BE Fk , QR ; TY Dt ; or ( An , & QR ) ; Dt = Jm ( QR ) ; Fs ( fi , QR , Dt ) ; } TY Jm ( BE km ) { Np ( km == 0 ) { hs 1 ; } be { hs km * Jm ( km - 1 ) ; } } '
    }
    let(:expect_code) {
      'TY Jm ( BE FR ) ; BE di ( Su ) { BE Fk , QR ; TY Dt ; or ( An , & QR ) ; Dt = Jm ( QR ) ; Fs ( fi , QR , Dt ) ; hs ( 0 ) ; } TY Jm ( BE km ) { Np ( km <= 1 ) hs 1 ; be hs km * Jm ( km - 1 ) ; } '
    }

    it {
      expect(subject).to match_array([[12, true], [15, false]])
    }
  end
end
