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

require 'ostruct'

class Courier::Service::Base
  class << self
    def inherited(subclass)
      subclass.instance_variable_set('@config', OpenStruct.new)
      super
    end

    def configure
      yield @config
    end

    def config
      @config
    end
  end

  def check_args owner, template, args
    # args[:text]||=template.get_text(self, args)
  end

  def message(owner, template, args)
    check_args owner, template, args
    Courier::Message.create! :owner=>owner, :template=>template.name, :service=>name, :options=>args
  end

  def to_s
    name
  end

  def to_label
    I18n::translate(:label, :scope=>[:courier, :services, name] )
  end

  def name
    self.class.name.demodulize.underscore.to_sym
  end

  def deliver_message(message)
    raise 'inherit and implement me'
  end

  def messages
    Courier::Message.by_service(name)
  end

  def deliver_all!
    messages.fresh.each do |message|
      deliver_message(message) and message.mark_as_delivered!
    end
  end
end
