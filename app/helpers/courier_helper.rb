# -*- coding: utf-8 -*-
module CourierHelper
  def toggle_subscription_link resource, sub=:new_comment, *args
    return '' unless current_user
    content_tag :span, :rel=>:tooltip, :title=>t('subscription.tooltip'), :class=>'toggle-subscription' do
      _toggle_subscription_link resource, sub, *args
    end
  end

  # resource = resource or subscriber
  def _toggle_subscription_link resource, sub=:new_comment, *args

    if resource.is_a? Courier::Subscriber
      _toggle_subscription_link_for_subscriber resource
    else
      create_subscription_link resource, sub
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
             'data-type'=>:jsonp)].join(' ').html_safe
  end

  def create_subscription_link *args
    [
      icon('volume-off')+t('subscription.deactivated').html_safe,
      link_to(
        t('subscription.activate'),
        create_subscription_url(*args),
        :format => :json,
        :remote => true,
        :class => 'toggle-subscription-link',
        'data-type' => :jsonp)
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
        'data-type' =>'jsonp')
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
end
