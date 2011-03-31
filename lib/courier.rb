# -*- coding: utf-8 -*-
module Courier
end

require 'courier/active_record'
ActiveRecord::Base.send(:extend, Courier::ActiveRecord )

#require 'gritter_notices/view_helpers' ActionView::Base.send(
#:include, GritterNotices::ViewHelpers )

# require 'gritter_notices/rspec_matcher'

require 'courier/engine' if defined?(Rails)


