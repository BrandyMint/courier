# -*- coding: utf-8 -*-

class Courier::Subscription::Base < ActiveRecord::Base
  INTERPOLATION_PATTERN = Regexp.new /%\{([a-z|0-9\._]+)\}/

  set_table_name :courier_subscriptions

  serialize :properties
  has_many :subscribers, :foreign_key=>:subscription_id, :class_name => 'Subscriber',
    :dependent => :destroy

  has_many :log_entities, :foreign_key => :subscription_id, :class_name => 'LogEntity'

  before_save do
    self.subject = self.description if self.subject.blank?
    self.properties = {} unless self.properties
  end

  # Запускаем рассылку по указанному ресурсу.
  # В параметрах можно передать send_at для запуска рассылки в определенное время.
  #
  def notify resource, params={}
    if use_delay?
      send_at = params.delete(:send_at) || Time.zone.now
      self.delay(run_at: send_at).real_notify(resource, params)
    else
      real_notify resource, params
    end
  end

  def real_notify resource = nil, params={}
    list = collect_subscribers resource, params
    list.each do |subscriber|
      safe_send_mail context_for_subscriber( resource, subscriber, params )
    end
  end

  def context_for_subscriber resource, subscriber, params
    context = OpenStruct.new params.merge(
      :subscription => self,
      :resource => resource,
      :subscriber => subscriber,

      :to => subscriber.to,
      :from => from
    )

    context.subject = get_subject(context)

    context
  end

  def context_for_user user, resource=nil, params={}
    context = OpenStruct.new params.merge(
      :subscription => self,
      :resource => resource,
      :user => user,

      :to => user.email_to,
      :from => from
    )

    context.subject = get_subject(context)

    context
  end

  def send_user_mail user, *args
    safe_send_mail context_for_user(user), *args
  end

  def send_mail context, *args
    # Подготавливаем сообщение
    message = mailer_class.send name, context, *args

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

  def collect_subscribers resource=nil, params={}
    list = subscribers.by_resource resource
    list = list.without_users params[:exclude_users] if params[:exclude_users]
    list
  end

  def use_delay?
    not (Rails.env.test? or Rails.env.development?)
  end

  def subscribe *users
    options = users.extract_options!
    save

    users.each do |user|
      user = User.find_for_auth(user) unless user.is_a? User

      subscribe_user user, options[:resource] || options[:to]
    end
  end

  def subscribe_user user, resource = nil
    s = get_subscriber user, resource
    if s
      s.activate unless s.active?
      s
    else
      subscribers.create(user: user, resource: resource)
    end
  end

  def get_subscriber user, resource = nil
    if resource.present?
      resource.subscribers.where(user_id: user.id, subscription_id: id).first
    else
      subscribers.where(user_id: user.id, resource_id: nil).first
    end
  end

  def unsubscribe_user user, resource=nil, opts={}
    s = get_subscriber user, resource
    s.deactivate
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
