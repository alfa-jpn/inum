require 'rubygems'
require 'bundler/setup'
require 'inum/base'
require 'inum/define_check_method'
require 'inum/utils'
require 'i18n'

RSpec.configure do |config|
  config.mock_framework = :rspec
end
