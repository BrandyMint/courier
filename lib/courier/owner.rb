# -*- coding: utf-8 -*-


# # Courier::Sender (extenstion для AR-модели пользователя-отправителя)

# Подключается через `acts_as_sender` дает модели метод `message(key, options)`. Пример вызова:

# @@@
# user.notify :comments_in_my_plan, :comments=>@comments, :level=>:success
# user.notify_failure :cant_import_plans, :provider=>:facebook
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
        courier.enabled?(template, service, args) and service.message(self, template, args)
      end
    end
  end
end
