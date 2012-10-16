# -*- coding: utf-8 -*-
# Базовый класс который привносит сахарка в нашу жизнь.
# Если не указан ресурс мы считаем что используеются все ресурсы
module Courier

  def self.table_name_prefix
    'courier_'
  end

  def self.notify subscription_list, resource=nil, params={}
    subscription_list = Courier::SubscriptionList.find_by_name! subscription_list unless subscription_list.is_a? Courier::SubscriptionList
    subscription_list.subscription_type.notify subscription_list, resource, params
  end

  def self.custom_notify subscription_list, subscription_type, resource=nil, params={}
    subscription_list = Courier::SubscriptionList.find_by_name! subscription_list unless subscription_list.is_a? Courier::SubscriptionList
    subscription_type.notify subscription_list, resource, params
  end

  # Подписывает юзера на лист рассылки по ресурсу. Находит в базе лист рассылки
  # (если класс аргумента не валидный) и вызывает в его контексте
  # {Courier::SubscriptionList#subscribe} с указанными параметрами юзера и ресурса
  # ==Пример подписки на ресурс
  #  Courier.subscribe current_user, :new_comment, Comment.last
  # ==Пример подписки на все ресурсы
  #  Courier.subscribe current_user, :new_comments
  def self.subscribe user, subscription_list, resource=nil, params={}
    subscription_list = Courier::SubscriptionList.find_by_name! subscription_list unless subscription_list.is_a? Courier::SubscriptionList
    subscription_list.subscribe user, resource, params
  end

  # Отписывает юзера от листа рассылки по ресурсу. Находит в базе лист рассылки
  # (если класс аргумента не валидный) и вызывает в его контексте
  # {Courier::SubscriptionList#unsubscribe} с указанными параметрами юзера и ресурса
  # ==Пример отписки от ресурс
  #  Courier.unsubscribe current_user, :new_comment, Comment.last
  def self.unsubscribe user, subscription_list, resource=nil
    subscription_list = Courier::SubscriptionList.find_by_name! subscription_list unless subscription_list.is_a? Courier::SubscriptionList
    subscription_list.unsubscribe user, resource
  end
end

require 'courier/active_record_ext'
ActiveRecord::Base.extend Courier::ActiveRecordExt

require 'courier/engine'
