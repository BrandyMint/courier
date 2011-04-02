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
    args[:owner]  ||=owner
    args[:text]   ||=template.get_text(args)
    args[:service]||=self
  end

  def message(owner, template, args)
    check_args owner, template, args
    courier_messages.create! :owner=>owner, :template=>template, :options=>args
  end

  def name
    self.class.name.demodulize.underscore.to_sym
  end

  def deliver!
    raise 'inherit my class and implement me'
  end
end
