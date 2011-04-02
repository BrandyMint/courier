# -*- coding: utf-8 -*-

class Courier::Service::Facebook < Courier::Service::Base

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
    message.owner.respond_to?(:facebook_token) or
      raise "method facebook_token is not defined in your owner's model #{owner.class}"
    token = message.owner.facebook_token or raise "owner's facebook_token is empty"

    unless args = message.options[:facebook_properties]
      args = message.options.slice(:from, :to, :picture, :link, :name, :caption, :message,
        :description, :source, :icon, :attribution, :actions, :privacy, :targeting)
    end
    args[:message] ||= message.options[:text] || Courier.template(message.template).get_text(message.service, message.options)
    Koala::Facebook::GraphAPI.new(token).put_object(args[:to] || 'me', "feed", args)
  end
end
