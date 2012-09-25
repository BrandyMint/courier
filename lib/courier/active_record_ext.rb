# -*- coding: utf-8 -*-
module Courier::ActiveRecordExt

  def be_subscriber
    extend ClassMethods
    include InstanceMethods

    has_many :user_subscribers,
      :class_name => 'Courier::Subscriber',
      :dependent => :destroy
  end

  module ClassMethods

  end

  module InstanceMethods
    def subscribe sub, resource=nil, options={}
      sub = Courier.get! sub if sub.is_a? Symbol
      sub.subscribe_user self, resource
    end

    def unsubscribe sub, resource=nil, options={}
      sub = Courier.get! sub if sub.is_a? Symbol
      sub.unsubscribe_user self, resource, options
    end

    def get_subscriber sub, resource=nil
      sub = Courier.get! sub if sub.is_a? Symbol
      sub.get_subscriber self, resource
    end

    def send_mail sub, *args
      s = Courier.get! sub
      s.send_user_mail self, *args
    end

  end

  # примеры
  # has_subscriptions :to_title
  #
  # has_subscriptions do
  #   "Блог: #{name}"
  # end

  def has_subscriptions params={}
    @courier_resource_title = params[:title]
    has_many :subscribers,
      :class_name => 'Courier::Subscriber',
      :as => :resource,
      :dependent => :destroy
  end

end
