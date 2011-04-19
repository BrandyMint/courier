# -*- coding: utf-8 -*-

class Courier::Service::Facebook < Courier::Service::Base

  FACEBOOK_PROPERTY_ATTRS = [:from, :to, :picture, :link, :name, :caption, :description, :message,
    :source, :icon, :attribution, :actions, :privacy, :targeting]

  def initialize
    raise "No Koala defined. Add gem 'koala' to your Gemfile. " unless defined? Koala
    attr_accessor={}
    super
  end

  #
  # message.options[:facebook_properties] are all available options from
  # http://developers.facebook.com/docs/reference/api/post/
  #
  def deliver_message(message)
    args = message.options[:facebook_properties] || message.options.slice(FACEBOOK_PROPERTY_ATTRS)

    args[:message] ||= message.options[:text] || Courier.template(message.template).
      get_text(message.service, message.options)

    token = args[:token]
    token ||= message.owner.facebook_token if message.owner.respond_to?(:facebook_token)

    return true unless token

    to = args[:to] || (message.owner.respond_to?(:facebook_id) ? message.owner.facebook_id : nil) || 'me'

    # Settings.omniauth.facebook.app_id, Settings.omniauth.facebook.secret
    # Это post_on_wall
    Koala::Facebook::GraphAPI.new(token).put_object(to, "feed", args)
  end
end
