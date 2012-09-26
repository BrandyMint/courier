# -*- coding: utf-8 -*-

include BootstrapHelper

module CourierHelper

  def toggle_subscription_link resource, sub=:new_comment
    return '' unless current_user
    resource.is_a?(Courier::Subscriber) ? tooltip_class = resource.resource.class : tooltip_class = resource.class
    tooltip = t ("subscription.tooltip.#{tooltip_class}"), :default => [t("subscription.tooltip.default")]
    content_tag :span, :rel=>:tooltip, :title=>tooltip, :class=>'toggle-subscription' do
      _toggle_subscription_link resource, sub
    end
  end

  # resource = resource or subscriber
  def _toggle_subscription_link resource, sub=:new_comment

    if resource.is_a? Courier::Subscriber
      _toggle_subscription_link_for_subscriber resource
    else
      subscriber = Courier::Subscriber.where(
          user_id: current_user.id,
          resource_id: resource.id,
          resource_type: resource.class.model_name
      ).first
      if subscriber.present?
        deactivate_subscription_link subscriber
      else
        create_subscription_link resource, sub
      end
    end
  end

  def _toggle_subscription_link_for_subscriber subscriber
    if subscriber.persisted?
      if subscriber.active?
        deactivate_subscription_link subscriber
      else
        activate_subscription_link subscriber
      end
    else
      create_subscription_link subscriber.resource, subscriber.subscription.name
    end
  end

  def deactivate_subscription_link subscriber
    [icon('volume-up')+t('subscription.activated').html_safe, 
     link_to( t('subscription.deactivate'),
             deactivate_subscription_url(subscriber),
             :format => :json,
             :remote => true,
             :class  => 'toggle-subscription-link',
             'data-type'=>:jsonp),
    subscribers_count(subscriber)
    ].join(' ').html_safe
  end

  def create_subscription_link resource, sub
    [
      icon('volume-off')+t('subscription.deactivated').html_safe,
      link_to(
        t('subscription.activate'),
        create_subscription_url(resource, sub),
        :format => :json,
        :remote => true,
        :class => 'toggle-subscription-link',
        'data-type' => :jsonp),
      subscribers_count(resource, sub)
    ].join(' ').html_safe
  end

  def activate_subscription_link subscriber
    [
      icon('volume-off')+t('subscription.deactivated').html_safe,
      link_to(
        t('subscription.activate'),
        activate_subscription_url(subscriber),
        :format => :json,
        :remote =>true,
        :class =>'toggle-subscription-link',
        'data-type' =>'jsonp'),
      subscribers_count(subscriber)
    ].join(' ').html_safe
  end

  def activate_subscription_url subscriber
    urls.activate_api_subscription_url subscriber, :json
  end

  def create_subscription_url resource, subscription
    urls.create_and_activate_api_subscriptions_url(
      :resource_type => resource.class.name,
      :resource_id   => resource.id,
      :subscription_name  => subscription,
      :format => :json
    )
  end

  def deactivate_subscription_url subscriber
    urls.deactivate_api_subscription_url subscriber, :json
  end

  def subscribers_count resource, sub=nil
    if resource.is_a? Courier::Subscriber
      subscription = resource.subscription
      resource = resource.resource
    else
      subscription = Courier::Subscription::Base.find_by_name(sub)
    end
    # здесь так потому что resource то может быть и nil
    count = Courier::Subscriber.by_resource(resource).by_subscription(subscription).active.count
    # если делать на хелперах вылазит ошибка undefined method `output_buffer='
    # инклюдинг TagHelper дело не меняет, добавление атрибута output_buffer ломает тесты
    "<span class='subscribers_count'>(#{count})</span>"
  end
  
  def check_subscription user, subscription_name, resource=nil, opts={}
    subscription = Courier::Subscription::Base.find_by_name(subscription_name)
    if resource.nil?    
      subscriber = Courier::Subscriber.where(user_id: user.id, subscription_id: subscription.id).first
    else
      subscriber = Courier::Subscriber.where(user_id: user.id, subscription_id: subscription.id, resource_id: resource.id).first
    end
    subscriber.present?
  end
end

