# -*- coding: utf-8 -*-

# Подключается через `has_courier` дает модели метод `message(key, options)`. Пример вызова:
#
# @@@
# user.message :comments_in_my_plan, :comments=>@comments, :level=>:success
# @@@


module Courier::Owner
  def has_courier
    has_one :courier, :as => :owner, :dependent => :destroy, :class_name=>'Courier::OwnerSetting'
    has_many :courier_messages, :as => :owner, :dependent => :destroy, :class_name=>'Courier::Message'
    include InstanceMethods

    after_create do
      create_courier
    end
  end

  module InstanceMethods
    def message(template_key, args={})
      template = Courier.template(template_key)
      Courier.config.services_order.select do |service|
        create_courier unless courier
        courier.on?(template, service, args) and service.message(self, template, args)
      end
    end
  end
end
