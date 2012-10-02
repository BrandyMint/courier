# -*- coding: utf-8 -*-
class Courier::SubscriptionsController < ::ApplicationController
  respond_to :json, :html
  before_filter :authorize_user!

  include CourierHelper
  include ActionView::Helpers::UrlHelper

  def create_and_activate
    render_toggle_link subscription
  end

  def activate
    subscription.activate
    render_toggle_link subscription
  end

  def deactivate
    subscription.deactivate
    respond_with do |format|
      format.json { render_toggle_link subscription }
      format.html { redirect_to params[:backurl] || urls.root_url, notice: "Отписка прошла успешно" }
    end
  end

  def show
    @subscription = subscription
  end

  private

  def subscription
    @subscription ||= if params[:id]
      current_user.subscriber_subscriptions.find_by_id( params[:id] )
    else
      Courier.subscribe current_user, subscription_list, resource
    end
  end

  def subscription_list
    if params[:subscription_list_name]
      Courier::SubscriptionList.find_by_name! params[:subscription_list_name]
    else
      Courier::SubscriptionList.find params[:subscription_list_id]
    end
  end

  def resource
    if params[:resource_id].nil?
      nil
    else  
      @resource ||= params[:resource_type].constantize.find( params[:resource_id] )
    end
  end

  def render_toggle_link subscription
    render :json => { :html => _toggle_subscription_link(subscription).html_safe },
      :callback => params[:callback]
  end
end
