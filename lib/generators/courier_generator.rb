require 'rails/generators'
require 'rails/generators/migration'

class CourierGenerator < Rails::Generators::Base
  desc "This generator creates an initializer file at config/initializers/courier.rb and migration file."

  include Rails::Generators::Migration

  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end

  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_migration_file
    migration_template 'migration.rb', 'db/migrate/create_courier_tables.rb'
  end

  def create_initializer_file
    copy_file "courier.rb", "config/initializers/courier.rb"
    # create_file "config/initializers/courier.rb", "# Add initialization content here"
  end
end
