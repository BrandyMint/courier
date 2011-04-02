# -*- coding: utf-8 -*-
module Courier
  require 'courier/owner_setting'
  require 'courier/config'
  module Service
    require 'courier/service/base'
    Dir["#{File.dirname(__FILE__)}/courier/service/**/*.rb"].each {|f| require f}
  end
  module Template
    require 'courier/template/base'
  end

  class << self
    cattr_accessor :config

    def init
      yield self.config = Courier::Config.new
    end

    def deliver_all!
      config.services.each do |service|
        service.deliver_all!
      end
    end

    def template(name)
      config.get_template(name)
    end

    def service(name)
      config.get_service(name)
    end
  end
end

require 'courier/message'

require 'courier/owner'
ActiveRecord::Base.send(:extend, Courier::Owner )

#require 'gritter_notices/view_helpers' ActionView::Base.send(:include, GritterNotices::ViewHelpers )
# require 'gritter_notices/rspec_matcher'

require 'courier/engine' if defined?(Rails)


