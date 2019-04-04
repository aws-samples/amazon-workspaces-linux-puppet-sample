require 'spec_helper'
describe 'linuxws' do
  context 'with default values for all parameters' do
    it { should contain_class('linuxws') }
  end
end
