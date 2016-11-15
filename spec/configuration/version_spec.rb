require 'spec_helper'

describe 'GrapeOAuth2 Version' do
  it 'has a version string' do
    expect(GrapeOAuth2::VERSION::STRING).to be_present
  end

  it 'returns version as an instance of Gem::Version' do
    expect(GrapeOAuth2.gem_version).to be_an_instance_of(Gem::Version)
    expect(GrapeOAuth2.version).to be_an_instance_of(Gem::Version)
  end
end
