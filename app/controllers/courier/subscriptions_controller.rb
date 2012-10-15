# -*- coding: utf-8 -*-
# Контроллер по управлению подписками, подключается в роутах rails приложения

class Courier::SubscriptionsController < ::ApplicationController
  respond_to :json, :html
  before_filter :authorize_user!, :except=>[:show, :deactivate_by_token]

  include CourierHelper
  include ActionView::Helpers::UrlHelper

  def create_and_activate
    subscription_list = Courier::SubscriptionList.find_by_name! params[:subscription_list_name]
    resource = params[:resource_type].constantize.find( params[:resource_id] )
    Courier.subscribe current_user, subscription_list, resource
    render_toggle_link subscription_list, resource
  end

  def activate
    subscription = current_user.subscriber_subscriptions.find params[:id]
    subscription.activate
    render_toggle_link subscription.subscription_list, subscription.resource
  end

  def deactivate
    subscription = current_user.subscriber_subscriptions.find params[:id]
    subscription.deactivate
    respond_with do |format|
      format.json { render_toggle_link subscription.subscription_list, subscription.resource }
      format.html { redirect_to params[:backurl] || urls.root_url, notice: "Отписка прошла успешно" }
    end
  end

  def show
    @subscription = Courier::Subscription.where(token:params[:id]).first
  end

  def deactivate_by_token
    subscription =  Courier::Subscription.find_by_token! params[:id]
    subscription.deactivate
    redirect_to params[:backurl] || urls.root_url, notice: "Отписка прошла успешно"
  end

  private

  def render_toggle_link subscription_list, resource
    output = render_cell :subscription, :show, subscription_list, resource
    render :json => { :html => output.html_safe },
      :callback => params[:callback]
  end
end
