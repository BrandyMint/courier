# -*- coding: utf-8 -*-
# Модель описывающая подписку пользователя на определенный лист рассылки({Courier::SubscriptionList}) по определенному ресурсу.
# Если ресурс равен nil, мы считаем что пользователь подписан на все ресурсы.
class Courier::Subscription < ActiveRecord::Base

  belongs_to :user
  belongs_to :subscription_list, :class_name => 'Courier::SubscriptionList'

  belongs_to :resource, :polymorphic => true

  scope :active, where(is_active: true)

  scope :exclude_users, lambda{ |users|
    where("user_id not in (?)", users.map(&:id))
  }

  scope :by_subscription_list, lambda{ |subscription_list| where(subscription_list_id: subscription_list.id)}

  scope :by_resource, lambda{ |resource|
    resource ? where(resource_id: resource.id, resource_type: resource.class.base_class.model_name) : where(resource_id: nil)
  }

  validates :user, :presence => true
  validates :subscription_list, :presence => true
  validates :token, presence: true, uniqueness: true

  validates :subscription_list_id, :uniqueness => {:scope => [:user_id, :resource_id, :resource_type]}

  before_validation :check_token

  delegate :to_s, :to_label, :email, :to => :user
  delegate :description, :access, :to => :subscription_list

  # Активна подписка или нет
  def active?
    persisted? and is_active
  end

  # кому отправляется письмо
  def to
    user.email_to
  end

  # активирует подписку
  def activate
    update_attribute :is_active, true
  end

  # деактивирует подписку если в листе рассылки({Courier::SubscriptionList}) sticky равен true,
  # иначе удаляет рассылку
  def deactivate
    if subscription_list.sticky
      update_attribute :is_active, false
    else
      destroy
    end
  end

  # делает подписку временной/постоянной
  def set_temporary val
    update_attribute :temporary, val
  end

  # Название подписки, используется поле description из Листа
  # Рассылки({Courier::SubscriptionList}) и кастомная часть ресурса
  # {Courier::Subscription#resource_title}
  def title
    return description unless resource

    [description, resource_title].join ' '
  end

  # Часть названия подписки, вычисляемая по ресурсу, к которому привязана подписка.
  # Настройки названий устанавливаются непосредственно в ресурсе при вызове
  # {Courier::ActiveRecordExt#has_subscriptions}
  def resource_title
    return '' unless resource.present?

    courier_resource_title = self.resource.class.instance_variable_get(:@courier_resource_title)

    if courier_resource_title
      if courier_resource_title.is_a?(Proc)
        resource.instance_exec(&courier_resource_title)
      else
        resource.send(courier_resource_title)
      end
    else
      "#{resource.class}##{resource.id}"
    end
  end

  # ссылка на ресурс, если он существует
  def resource_url
    return nil unless resource
    if resource.respond_to? :url
    else
      polymorphic_url resource
    end
  end

  protected

  # проверка на наличие уникального токена
  def check_token
    return if self.token and !self.token.blank?
    token = generate_token(20)
    while Courier::Subscription.find_by_token(token)
      token = generate_token(20)
    end
    self.token = token
  end

  # генерация токена
  def generate_token(length)
    o =  [('0'..'9'),('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    (0..length).map{ o[rand(o.length)]  }.join
  end

end
