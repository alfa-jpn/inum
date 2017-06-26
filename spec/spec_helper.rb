require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'coveralls'
require 'inum'

RSpec.configure do |config|
  config.color = true
  config.mock_framework = :rspec
  config.before(:all) {
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
    I18n.enforce_available_locales = false
  }
end

Coveralls.wear!

def create_temp_table(name, &block)
  raise 'No Block given!' unless block_given?

  before :all do
    migration = ActiveRecord::Migration.new
    migration.verbose = false
    migration.create_table name, &block
  end

  after :all do
    migration = ActiveRecord::Migration.new
    migration.verbose = false
    migration.drop_table name
  end
end
