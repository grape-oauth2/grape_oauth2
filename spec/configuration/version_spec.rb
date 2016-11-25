require 'spec_helper'

describe 'Grape::OAuth2 Version' do
  it 'has a version string' do
    expect(Grape::OAuth2::VERSION::STRING).to be_present
  end

  it 'returns version as an instance of Gem::Version' do
    expect(Grape::OAuth2.gem_version).to be_an_instance_of(Gem::Version)
    expect(Grape::OAuth2.version).to be_an_instance_of(Gem::Version)
  end
end
