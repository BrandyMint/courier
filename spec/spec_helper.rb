# -*- coding: utf-8 -*-
require 'rubygems'
require "bundler/setup"

ENV["RAILS_ENV"] ||= 'test'

require 'active_record'
require 'action_view'
require 'action_controller'
require 'state_machine'

require 'rspec'
require 'rspec/rails'
require 'shoulda'
require 'factory_girl'

# require 'nulldb_rspec'
# include NullDB::RSpec::NullifiedDatabase

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ":memory:"
   # :adapter => 'postgresql',
   # :database => "courier_test"

  )

#ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a'))

require 'lib/generators/templates/migration'
CreateCourierTables.migrate :up

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
  end
end

require 'courier'


Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  # config.include GritterNotices::RSpecMatcher
end
