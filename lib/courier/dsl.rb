# -*- coding: utf-8 -*-

class Courier::DSL
  attr_accessor :subscription

  def initialize subscription
    self.subscription = subscription
  end

  # Это чтобы из Courier.create можно было легко
  # устанавливать значения подписки
  #
  def method_missing method, *args
    if subscription.has_attribute? method
      subscription.send "#{method}=", *args
    elsif subscription.respond_to? method
      subscription.send method, *args
    else
      super
    end
  end

end
