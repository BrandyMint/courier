# encoding: utf-8

class Courier::SubscribersController < ApplicationController
  def show
    @subscriber = Courier::Subscriber.find_by_token(params[:id])

    if @subscriber
      login_user @subscriber.user
    end

    respond_with @subscriber
  end
end
