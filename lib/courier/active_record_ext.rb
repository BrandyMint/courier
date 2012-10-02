# -*- coding: utf-8 -*-
module Courier::ActiveRecordExt

  def be_subscriber
    has_many :subscriber_subscriptions,
      :class_name => 'Courier::Subscription',
      :dependent => :destroy
  end

  # примеры
  # has_subscriptions :to_title
  #
  # has_subscriptions do
  #   "Блог: #{name}"
  # end

  def has_subscriptions params={}
    @courier_resource_title = params[:title]
    has_many :resource_subscriptions,
      :class_name => 'Courier::Subscription',
      :as => :resource,
      :dependent => :destroy
  end

end
