# -*- coding: utf-8 -*-

# Модель класса осуществляющего способ доставки.

# * name - уникальное название (littlesms, actionmailer)
# * type (класс)

# ## Например:

# * Courier::Service::SMS::LittleSMS
# * Courier::Service::Email::ActionMailer
# * Courier::Service::Email::MailChimp
# * Courier::Service::Twitter::Grackle
# * Courier::Service::Flash::GritterNotice

# доставщики подключаются через команду
# Courier.register_service(SMS::LittleSMS, Email::ActionMailer,.. )


class Courier::Service::Base < ActiveRecord::Base
  set_table_name 'courier_services'

  has_many :courier_owner_sets, :class_name=>"Courier::OwnerSet", :dependent=>:destroy, :foreign_key=>:service_id #, :as=>:service
  has_many :courier_messages, :class_name=>"Courier::Message", :dependent=>:destroy, :foreign_key=>:service_id

  before_validation :set_name

  validates_presence_of :name, :type
  validates_uniqueness_of :name

  default_scope order('id')
  scope :enabled_for_owner, lambda { |owner| include(:courier_owner_sets).where(:owner=>owner) }

  def message(owner, template, args)
    courier_messages.create! :owner=>owner, :template=>template, :options=>args
  end

  def name
    read_attribute('name') || self.class.name.split('::').last
  end

  def deliver!
    raise 'inherit my class and implement me'
  end

  private

  def set_name
    self.name = name
  end
end
