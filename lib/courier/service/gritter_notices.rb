# -*- coding: utf-8 -*-

class Courier::Service::GritterNotices < Courier::Service::Base
  def message(owner, template, *args)
    owner.gritter_notice template.key, *args
  end

  def deliver!
    # Nothng to do, it's realtime delivered
  end
end
