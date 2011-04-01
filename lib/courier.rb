# -*- coding: utf-8 -*-
module Courier
  require 'courier/owner_set'
  module Service
    require 'courier/service/base'
    require 'courier/service/active_mailer'
    require 'courier/service/gritter_notices'
  end
  module Template
    require 'courier/template/base'
  end

  # TODO Cache
  class << self
    def template(key)
      Courier::Template::Base.find_by_key(key) or raise "No such template '#{key}' found"
    end

    def templates
      Courier::Template::Base.all
    end

    def register_templates(*templates)
      templates.each do |templ|
        Courier::Template::Base.create! :key=>templ
      end
    end

    def register_services(*services)
      services.each do |service_class|
        service_class.create!
      end
    end

    def services
      Courier::Service::Base.all
    end

    def deliver_all!
      services.each do |service|
        service.deliver!
      end
    end
  end
end

require 'courier/message'

require 'courier/owner'
ActiveRecord::Base.send(:extend, Courier::Owner )

#require 'gritter_notices/view_helpers' ActionView::Base.send(:include, GritterNotices::ViewHelpers )
# require 'gritter_notices/rspec_matcher'

require 'courier/engine' if defined?(Rails)


