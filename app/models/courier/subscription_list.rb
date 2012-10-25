# -*- coding: utf-8 -*-
# Класс описывающий Листы рассылок, на которые может быть подписан пользователь, и реализущий логику подписки/отписки.
# Лист рассылки имеет ссылку на дефолтный способ рассылки({Courier::SubscriptionType})
class Courier::SubscriptionList < ActiveRecord::Base
  has_many :subscriptions, :foreign_key=>:subscription_list_id, :class_name => 'Subscription',
           :dependent => :destroy

  belongs_to :subscription_type, :class_name => 'SubscriptionType::Base'

  # Добавляет пользователя в текущий лист рассылки по заданному ресурсу.
  # Если пользователь уже в листе и не активен - активирует его подписку
  def subscribe user, resource = nil, params={temporary: false}
    s = get_subscription user, resource
    if s
      s.set_temporary params[:temporary]
      s.activate unless s.active?
      s
    else
      subscriptions.create(user: user, resource: resource, temporary: params[:temporary])
    end
  end

  # Отписывает пользователя из текущего листа рассылки по заданному ресурсу.
  # Находит подписку и вызывает {Courier::Subscription#deactivate}
  def unsubscribe user, resource = nil
    s = get_subscription user, resource
    s.deactivate
  end

  # Получает список всех подписок({Courier::Subscription}) этого листа по заданному ресурсу
  def collect_subscriptions resource=nil, params={exclude_users:nil}
    list = subscriptions.by_resource resource
    list = list.exclude_users params[:exclude_users].compact if params[:exclude_users]
    list
  end

  # Получает подписку юзера этого листа по заданному ресурсу
  def get_subscription user, resource = nil
    subscriptions.by_resource(resource).where(user_id: user.id).first
  end
end
