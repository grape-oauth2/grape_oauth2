require 'spec_helper'

describe GrapeOAuth2::Scopes do
  context '#valid_for?' do
    it 'true when all the requested scopes included in the Access Token scopes' do
      scopes = described_class.new(['read', 'write'])
      access_token = double('AccessToken', scopes: 'read write')

      expect(scopes.valid_for?(access_token)).to be_truthy
    end

    it 'true when requested scopes are empty' do
      scopes = described_class.new([])
      access_token = double('AccessToken', scopes: 'read write')

      expect(scopes.valid_for?(access_token)).to be_truthy
    end

    it 'false when some of the requested scopes does not included in the Access Token scopes' do
      scopes = described_class.new(['read', 'write', 'destroy'])
      access_token = double('AccessToken', scopes: 'read write')

      expect(scopes.valid_for?(access_token)).to be_falsey
    end
  end

  context '#to_array' do
    let(:scopes) { described_class.new([]) }

    it 'converts the String scopes to an Array' do
      expect(scopes.send(:to_array, 'read write delete')).to eq(%w(read write delete))
    end

    it 'converts the object that responds to `to_a` to an Array' do
      custom_scopes = double('CustomScopes')
      allow(custom_scopes).to receive(:to_a).and_return(%w(read write))

      expect(scopes.send(:to_array, custom_scopes)).to eq(%w(read write))
    end

    it 'returns an Array of String values if Array was passed' do
      expect(scopes.send(:to_array, %w(read write delete))).to eq(%w(read write delete))
      expect(scopes.send(:to_array, %i(read write delete))).to eq(%w(read write delete))
    end

    it 'raises an error if scopes type is not supported' do
      expect { scopes.send(:to_array, :read) }.to raise_error(ArgumentError)
    end
  end
end
