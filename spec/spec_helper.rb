# -*- coding: utf-8 -*-
require 'rubygems'
require "bundler/setup"

ENV["RAILS_ENV"] ||= 'test'

require 'rails/all'

require 'state_machine'

require 'rspec'
require 'rspec/rails'
require 'shoulda'
require 'factory_girl'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ":memory:"

  )

class Application < Rails::Application; end

require 'lib/generators/templates/migration'
CreateCourierTables.migrate :up

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.string :name
  end
end

require 'courier'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

require 'config/routes'
require 'app/controllers/courier_settings_controller'
require 'app/helpers/courier_settings_helper'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.use_transactional_examples = true
  # config.include GritterNotices::RSpecMatcher
end
