require 'rubygems'
require 'bundler/setup'
require 'inum/base'
require 'inum/define_check_method'
require 'inum/utils'

RSpec.configure do |config|
  config.mock_framework = :rspec
end
