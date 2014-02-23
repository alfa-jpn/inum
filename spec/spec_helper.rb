require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'inum'

RSpec.configure do |config|
  config.mock_framework = :rspec
  config.before(:all) {
    Dir.mkdir('tmp') unless Dir.exists?('tmp')
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'tmp/rspec.sqlite')
    I18n.enforce_available_locales = false
  }
end

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
