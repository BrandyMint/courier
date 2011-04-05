require 'spec_helper'

describe CourierSettingsController do

  before do
    @current_user = Factory :user
    # @request.env["devise.mapping"] = :user
    # sign_in @current_user
  end
  # let(:current_user){ @current_user }

  describe "GET 'set'" do
    it "should be successful" do
      pending
      courier = double :courier
      courier.should_receive :set!
      controller.current_user.stub('courier') { courier }
      # controller.stub(:url_for)
      get 'set', :service=>:service, :template=>:template, :value=>:on
      response.should be_success
    end
  end
end
