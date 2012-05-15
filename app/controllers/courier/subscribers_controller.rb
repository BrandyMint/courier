# encoding: utf-8

class Courier::SubscribersController < ApplicationController
  def show
    @subscriber = Courier::Subscriber.find_by_token(params[:id])

    if @subscriber
      login_user @subscriber.user
    end

    respond_with @subscriber
  end

  def deactivate
    notice = nil

    @subscriber = Courier::Subscriber.find_by_token(params[:id])
    if @subscriber
      if @subscriber.is_active
        notice = "Вы отписаны от рассылки: #{@subscriber.title}."
        login_user @subscriber.user

        @subscriber.deactivate
      else
        login_user @subscriber.user

        notice = "Вы не подписаны на рассылку: #{@subscriber.title}."
      end

      redirect_to urls.personal_subscriptions_url, notice: notice
    else
      render :show
    end
  end
end
