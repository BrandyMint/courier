# -*- coding: utf-8 -*-

class Courier::SubscriptionType::Base < ActiveRecord::Base
  INTERPOLATION_PATTERN = Regexp.new /%\{([a-z|0-9\._]+)\}/

  self.table_name = :courier_subscription_types

  serialize :properties

  has_many :log_entities, :foreign_key => :subscription_type_id, :class_name => 'Courier::LogEntity'

  before_save do
    self.subject = self.description if self.subject.blank?
    self.properties = {} unless self.properties
  end

  # Запускаем рассылку по указанному ресурсу.
  # В параметрах можно передать send_at для запуска рассылки в определенное время.
  #
  def notify subscription_list, resource, params={}
    if use_delay?
      send_at = params.delete(:send_at) || Time.zone.now
      self.delay(run_at: send_at).real_notify(subscription_list, resource, params)
    else
      real_notify subscription_list, resource, params
    end
  end

  def real_notify subscription_list, resource = nil, params={}
    list = subscription_list.collect_subscriptions resource, params
    list.each do |subscription|
      safe_send_mail context( resource, subscription, params )
      subscription.deactivate if subscription.temporary?
    end
  end

  def context resource, subscription, params
    context = OpenStruct.new params.merge(
      :subscription_type => self,
      :resource => resource,
      :subscription => subscription,

      :to => subscription.to,
      :from => from
    )

    context.subject = get_subject(context)

    context
  end

  def send_mail context
    # Подготавливаем сообщение
    message = mailer_class.send context.subscription_type.name, context

    transaction do
      lock!(true)
      log_and_deliver message, context
    end
  end

  def log_and_deliver message, context
    begin
      Courier::LogEntity.save_mail message, context
      message.deliver
    rescue ActiveRecord::RecordInvalid => e
      logger.warn "Дупликат или ошибка логирования, не отправляю: #{context.to}/#{self}/#{context.object}: #{e.message}" # / #{e.record.errors.full_messages}"
    end
  end

  def safe_send_mail context
    begin
      send_mail context
    rescue Exception => e
      # TODO Log error
      if Rails.env.production?
        Airbrake.notify(e) if defined?(Airbrake)
      else
        raise(e)
      end
    end
  end

  def use_delay?
    not (Rails.env.test? or Rails.env.development?)
  end

  def mailer_class
    Courier::Mailer::Common
  end

  def get_subject object = nil
    interpolate subject, object || self
  end

  def to_s
    name
  end

  private

  # TODO Вынести в отдельный класс
  def interpolate string, object
    string.gsub(INTERPOLATION_PATTERN) do |match|
      if match == '%%'
        '%'
      else
        v = object
        $1.split('.').each do |m|
          unless v.respond_to? m
            v="No such method #{m} if object #{v}"
            break
          end
          v = v.send m
        end
        v.to_s
      end
    end
  end

end
