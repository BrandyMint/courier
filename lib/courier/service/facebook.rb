# -*- coding: utf-8 -*-

class Courier::Service::Facebook < Courier::Service::Base
  def initialize
    raise "No Koala defined. Add gem 'koala' to your Gemfile. " unless defined? Koala
    super
  end

  def check_args owner, template, args
    args[:to]|='me'
    args[:attachment]||={}
    super
  end

  def deliver!
    cache={}
    courier_messages.fresh.each do |message|
      message.owner.respond_to?(:facebook_token) or
        raise "method facebook_token is not defined in your owner's model #{owner.class}"
      token = message.owner.facebook_token or raise "owner's facebook_token is empty"
      graph = cache[token] ||= Koala::Facebook::GraphAPI.new(token)
      graph.put_wall_post(message.options[:text], message.options[:attachment], message.options[:to]) and
        message.set_delivered
    end
  end
end
