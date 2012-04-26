# -*- coding: utf-8 -*-
module Courier
  def self.table_name_prefix
    'courier_'
  end

  def self.get name
    Courier::Subscription::Base.find_by_name name
  end

  def self.get! name
    sub = get name
    raise "Can't find subscription #{name}" unless sub

    return sub
  end

  # name - имя рассылки
  # resource - ресурс к которому привязана рассылка
  # object - объект рассылки
  #
  # Например рассылка по новостям, связанным с компанией:
  #
  #   Courier.notify :company_news, company, news_item
  #
  def self.notify name, resource=nil, params={} #, *args
    s = get name
    raise "Пытаемся оповестить рассылку которой не существует #{name}" unless s
    s.notify resource, params
  end

  def self.create name, klass=Courier::Subscription::Base, &block
    puts "Create subscription: #{name}"
    s = Courier.get( name ) || klass.new( :name=>name )
    d = Courier::DSL.new s
    d.instance_exec &block
    s.save!
  end

  def self.subscribe user, sub_name, resource=nil, *args
    user.subscribe sub_name, resource, *args
  end

  def self.unsubscribe user, sub_name, resource=nil, *args
    user.unsubscribe sub_name, resource, *args
  end

  module Subscription

  end
end

require 'courier/active_record_ext'
ActiveRecord::Base.extend Courier::ActiveRecordExt

require 'courier/dsl'
require 'courier/engine'
