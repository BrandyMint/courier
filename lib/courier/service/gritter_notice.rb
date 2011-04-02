# -*- coding: utf-8 -*-

class Courier::Service::GritterNotice < Courier::Service::Base
  def initialize
    raise "No GritterNotices. Add gem 'gritter_notices' to Gemfile." unless defined? GritterNotices
    super
  end

  def message(owner, template, options)
    options[:scope]=[:courier,:messages,:gritter_notice] unless options[:scope]
    options[:text]=I18n::translate(name, options )
    owner.gritter_notice template.name, options
  end

  def deliver!
    # Nothng to do, it's realtime delivered
  end
end
