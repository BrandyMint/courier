class CourierSettingsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def set
    @result = current_user.courier.set!(@template=params[:template], @service=params[:service], params[:value])
  end
end
