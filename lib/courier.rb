# -*- coding: utf-8 -*-
module Courier

  # Кандидаты на вынос - current_user заменить на courier_current_subscriber и определять его в приложении
  # authorize_user! переименовать в courier_authorize_subscriber и также определять его в приложении

  def self.table_name_prefix
    'courier_'
  end

  # name - имя рассылки
  # resource - ресурс к которому привязана рассылка
  # object - объект рассылки
  #
  # Например рассылка по новостям, связанным с компанией:
  #
  #   Courier.notify :company_news, company, news_item
  #
  def self.notify subscription_list, resource=nil, params={} #, *args
    subscription_list = Courier::SubscriptionList.find_by_name! subscription_list unless subscription_list.is_a? Courier::SubscriptionList
    subscription_list.subscription_type.notify subscription_list, resource, params
  end

  def self.custom_notify subscription_list, subscription_type, resource=nil, params={} #, *args
    subscription_list = Courier::SubscriptionList.find_by_name! subscription_list unless subscription_list.is_a? Courier::SubscriptionList
    subscription_type.notify subscription_list, resource, params
  end

  def self.subscribe user, subscription_list, resource=nil, *args
    subscription_list = Courier::SubscriptionList.find_by_name! subscription_list unless subscription_list.is_a? Courier::SubscriptionList
    subscription_list.subscribe user, resource, *args
  end

  def self.unsubscribe user, subscription_list, resource=nil, *args
    subscription_list = Courier::SubscriptionList.find_by_name! subscription_list unless subscription_list.is_a? Courier::SubscriptionList
    subscription_list.unsubscribe user, resource, *args
  end
end

require 'courier/active_record_ext'
ActiveRecord::Base.extend Courier::ActiveRecordExt

require 'courier/engine'
