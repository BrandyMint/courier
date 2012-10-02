# -*- coding: utf-8 -*-

include BootstrapHelper

module CourierHelper

  def toggle_subscription_link resource, sub=:new_comment
    return '' unless current_user
    resource.is_a?(Courier::Subscription) ? tooltip_class = resource.resource.class : tooltip_class = resource.class
    tooltip = t ("subscription.tooltip.#{tooltip_class}"), :default => [t("subscription.tooltip.default")]
    content_tag :span, :rel=>:tooltip, :title=>tooltip, :class=>'toggle-subscription' do
      _toggle_subscription_link resource, sub
    end
  end

  # resource = resource or subscribtion
  def _toggle_subscription_link resource, sub=:new_comment

    if resource.is_a? Courier::Subscription
      _toggle_subscription_link_for_subscriber resource
    else
      subscription_list = Courier::SubscriptionList.find_by_name! sub
      subscription = Courier::Subscription.where(user_id: current_user.id, subscription_list_id: subscription_list.id).by_resource(resource).first
      if subscription.present?
        deactivate_subscription_link subscription
      else
        create_subscription_link resource, sub
      end
    end
  end

  def _toggle_subscription_link_for_subscriber subscription
    if subscription.persisted?
      if subscription.active?
        deactivate_subscription_link subscription
      else
        activate_subscription_link subscription
      end
    else
      create_subscription_link subscription.resource, subscription.subscription_list.name
    end
  end

  def deactivate_subscription_link subscription
    [icon('volume-up')+t('subscription.activated').html_safe, 
     link_to( t('subscription.deactivate'),
             deactivate_subscription_url(subscription),
             :format => :json,
             :remote => true,
             :class  => 'toggle-subscription-link',
             'data-type'=>:jsonp),
    subscribers_count(subscription)
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

  def activate_subscription_link subscription
    [
      icon('volume-off')+t('subscription.deactivated').html_safe,
      link_to(
        t('subscription.activate'),
        activate_subscription_url(subscription),
        :format => :json,
        :remote =>true,
        :class =>'toggle-subscription-link',
        'data-type' =>'jsonp'),
      subscribers_count(subscription)
    ].join(' ').html_safe
  end

  def activate_subscription_url subscription
    urls.activate_api_subscription_url subscription, :json
  end

  def create_subscription_url resource, subscription_list_name
    arguments = {:subscription_list_name => subscription_list_name, :format => :json}
    arguments.merge!({:resource_type => resource.class.base_class.model_name, :resource_id => resource.id}) unless resource.nil?
    urls.create_and_activate_api_subscriptions_url(arguments)
  end

  def deactivate_subscription_url subscription
    urls.deactivate_api_subscription_url subscription, :json
  end

  def subscribers_count resource, sub=nil
    subscription_list = nil
    if resource.is_a? Courier::Subscription
      subscription_list = resource.subscription_list
      resource = resource.resource
    else
      subscription_list = Courier::SubscriptionList.find_by_name(sub)
    end

    count = if resource
      resource.resource_subscriptions.by_subscription_list(subscription_list).active.count
    else
      Courier::Subscription.by_subscription_list(subscription_list).where(:resource_id=>nil).active.count
    end
    # если делать на хелперах вылазит ошибка undefined method `output_buffer='
    # инклюдинг TagHelper дело не меняет, добавление атрибута output_buffer ломает тесты
    "<span class='subscribers_count'>(#{count})</span>"
  end
end

