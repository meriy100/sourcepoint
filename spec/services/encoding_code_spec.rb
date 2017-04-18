require 'rails_helper'

RSpec.describe EncodingCode do
  describe 'EncodingCode#encode' do
    let(:encoding_code) { EncodingCode.new(src) }
    let(:src) {
<<C
#include <stdio.h>
int main() { /*
comment of multiple
*/

// comment
}
C
    }

    subject { encoding_code.encode }

    context 'with comment' do
      it do
        expect(subject.split(' ').count).to eq(12)
      end
    end

    context 'with number' do
    let(:src) {
<<C
#include <stdio.h>
int main() { /*
comment of multiple
*/
int i;
i = 10;
double a;
a = 23.0;
return 0;
// comment
}
C
}
      it do
        encode_code = subject.split(' ')
        expect(encode_code.count).to eq(31)
        expect(encode_code).to include('10')
        expect(encode_code).to include('23')
      end
    end

    context 'with <= => && ' do
    let(:src) {
<<C
/*
comment of multiple
*/
21==31
21<=31
21>=31
21&&31
21||31
21!=31
// comment
C
}
      it do
        encode_code = subject.split(' ')
        expect(encode_code.count).to eq(18)
      end
    end
  end
end
