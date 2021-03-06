require 'spec_helper'

API_DESC = 'POST /api/v1/test'
ANOTHER_API_DESC = 'GET /mostly/nested/test'

describe RSpec::Grape::Utils do
  describe '.find_endpoint_description' do
    subject { described_class.find_endpoint_description(self.class) }

    context 'when description is not found' do
      it { is_expected_to_raise(RSpec::Grape::NoEndpointDescription) }
    end

    context 'when description is found' do
      describe API_DESC do
        it { is_expected.to eq(API_DESC) }

        context 'with nested api description' do
          describe ANOTHER_API_DESC do
            it { is_expected.to eq(ANOTHER_API_DESC) }
          end
        end

        context 'inside nested context' do
          it { is_expected.to eq(API_DESC) }
        end
      end
    end
  end

  describe '.is_description_valid?' do
    def valid?(desc)
      described_class.is_description_valid?(desc)
    end

    context 'with valid description' do
      it 'returns true' do
        expect(valid?('GET /api/v1/test')).to be_truthy
        expect(valid?('GET /foo')).to be_truthy
        expect(valid?('GET /foo?bar=1')).to be_truthy
        expect(valid?('GET /')).to be_truthy
      end

      it 'knows all HTTP methods' do
        described_class::HTTP_METHODS.each do |method|
          expect(valid?("#{method} /valid/api/path")).to be_truthy
        end
      end
    end

    context 'with invalid description' do
      it 'returns false' do
        expect(valid?('OLOLO /valid/api/path')).to be_falsy
        expect(valid?('PUT api/v1/test')).to be_falsy
      end
    end
  end

  describe '.url_param_names' do
    context 'when url is not parameterized' do
      subject { described_class.url_param_names('/not/parameterized/url') }

      it { is_expected.to eq([]) }
    end

    context 'when url is parameterized' do
      context 'with one parameter' do
        subject { described_class.url_param_names('/url/with/:param') }

        it { is_expected.to eq([:param]) }
      end

      context 'with many parameters' do
        subject { described_class.url_param_names('/url/with/:many/:param/:id/') }

        it { is_expected.to eq([:many, :param, :id]) }
      end
    end
  end
end
