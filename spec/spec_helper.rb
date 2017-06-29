require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'inum'

require 'rspec'
require 'spec_helpers/active_record_helper'
require 'coveralls'

RSpec.configure do |config|
  config.color          = true
  config.mock_framework = :rspec
  config.before(:all) do
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
    I18n.enforce_available_locales = false
  end
end

Coveralls.wear!
