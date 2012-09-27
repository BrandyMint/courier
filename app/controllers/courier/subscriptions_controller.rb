# -*- coding: utf-8 -*-
class Courier::SubscriptionsController < ::ApplicationController
  respond_to :json, :html
  before_filter :authorize_user!

  include CourierHelper
  #include BootstrapHelper TODO: с ним не заводится, прекрасно работает и без него, удалить?
  include ActionView::Helpers::UrlHelper

  def create_and_activate
    render_toggle_link current_user.subscribe(subscription, resource)
  end

  def destroy
    subscriber.deactivate

    respond_with do |format|
      format.json { render_toggle_link subscriber }
      format.html { redirect_to params[:backurl] || urls.root_url, notice: "Отписка прошла успешно" }
    end
  end

  def deactivate
    destroy
  end

  def activate
    subscriber.activate

    render_toggle_link subscriber
  end

  private

  def subscription
    if params[:subscription_name]
      Courier.get! params[:subscription_name]
    else
      Courier::Subscription::Base.find params[:subscription_id]
    end
  end

  def subscriber
    @subscriber ||= if params[:id]
      current_user.user_subscribers.find_by_id( params[:id] )
    else
      current_user.subscribe( subscription, resource )
    end
  end

  def resource
    if params[:resource_id].nil?
      nil
    else  
      @resource ||= params[:resource_type].constantize.find( params[:resource_id] )
    end
  end

  def render_toggle_link subscriber
    render :json => { :html => _toggle_subscription_link(subscriber).html_safe },
      :callback => params[:callback]
  end
end
