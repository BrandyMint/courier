# -*- coding: utf-8 -*-

class Courier::Service::GritterNotice < Courier::Service::Base

  def initialize
    raise "No GritterNotices. Add gem 'gritter_notices' to Gemfile." unless defined? GritterNotices
    super
  end

  def message(owner, template, *args)
    owner.gritter_notice template.key, *args
  end

  def deliver!
    # Nothng to do, it's realtime delivered
  end
end
