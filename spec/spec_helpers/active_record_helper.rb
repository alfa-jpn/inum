# Create table.
# @param [String] name table name.
# @yield [t] table dsl block.
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
