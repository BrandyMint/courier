# -*- coding: utf-8 -*-
# Модуль расширяет ActiveRecord::Base, позволяя вызывать в рельсовых моделях методы {#be_subscriber} и {#has_subscriptions}
module Courier::ActiveRecordExt

  # Вызываем в модели User и получаем scope *subscriber_subscriptions*,
  # выдающий подписки({Courier::Subscription}) юзера
  #
  # == Примеры
  #  class User < ActiveRecord::Base
  #    be_subscriber
  #  end
  #
  #  u = User.new
  #  u.subscriber_subscriptions # => [...]

  def be_subscriber
    has_many :subscriber_subscriptions,
      :class_name => 'Courier::Subscription',
      :dependent => :destroy
  end

  # Вызываем в модели на которую можно подписаться, она будет считаться ресурсом подписки
  # и получает scope *resource_subscriptions*, выдающий подписки({Courier::Subscription}) на этот ресурс.
  #
  # == Параметры
  # title::
  #   имя метода(Symbol), или объект типа Proc, который будет вычислены в отношении объекта модели.
  #   Используется для задания названия подписки
  #
  # == Примеры использования функции
  # используем для указания заголовка метод объекта модели
  #  has_subscriptions :title => :to_label
  # используем для указания заголовка лямбду, блок кода которой будет вычислен в контексте объекта модели
  #  has_subscriptions :title => lambda{"Блог: #{name}"}
  #
  # == Пример кода модели
  #  class Blog < ActiveRecord::Base
  #    has_subscriptions :title => lambda{"Блог: #{name}"}
  #  end
  #
  #  b = Blog.new
  #  b.resource_subscriptions # => [...]

  def has_subscriptions params={title:nil}
    @courier_resource_title = params[:title]
    has_many :resource_subscriptions,
      :class_name => 'Courier::Subscription',
      :as => :resource,
      :dependent => :destroy
  end

end
