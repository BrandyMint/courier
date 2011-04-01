# -*- coding: utf-8 -*-


# # Courier::Sender (extenstion для AR-модели пользователя-отправителя)

# Подключается через `acts_as_sender` дает модели метод `message(key, options)`. Пример вызова:

# @@@
# user.notify :comments_in_my_plan, :comments=>@comments, :level=>:success
# user.notify_failure :cant_import_plans, :provider=>:facebook
# @@@


module Courier::Owner
  def has_courier
    has_many :courier_owner_sets, :as => :owner, :dependent => :destroy, :class_name=>'Courier::OwnerSet'
    has_many :courier_enabled_services, :through=>:courier_owner_sets, :conditions=>{:state=>:enabled}

    after_create :courier_bootstrap!
    include InstanceMethods
  end

  # bootstrap all owners!
  def courier_bootstrap_all!
    all.each do |o|
      o.courier_bootstrap!
    end
  end

  module InstanceMethods
    def courier
      @courier ||= Courier::OwnersObject.new(self)
    end

    def message(template_key, args={})
      template = Courier.template(template_key)
      courier_owner_sets.by_template(template).enabled.each do |set|
        set.message(args)
      end
    end

    #
    # Создает владельцу матрицу owner_sets - по записи для каждого шаблона и каждого сервиса
    #
    def courier_bootstrap!
      Courier.services.each do |service|
        Courier.templates.each do |template|
          courier_owner_sets.create(:template=>template, :service=>service)
        end
      end
    end
  end
end
