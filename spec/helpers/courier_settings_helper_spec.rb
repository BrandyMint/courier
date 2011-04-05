require 'spec_helper'

describe CourierSettingsHelper do
  let!(:user) { Factory :user }
  let(:template) { mock_template }
  let(:service) { mock_service }

  # include ActionView::Helpers::TagHelper
  # include ActionView::Helpers::UrlHelper
  # include Rails.application.routes.url_helpers

  it 'should return disabled icon when disabled' do
    courier = double :courier
    courier.should_receive(:disabled?) { true }
    user.stub(:courier) { courier }
    helper.should_receive(:image_tag).with('disabled.png')

    helper.courier_setting_link(user, template, service)
  end

   it "should return 'on' icon when is on" do
    courier = double :courier
    courier.should_receive(:disabled?) { false }
    courier.should_receive(:on?) { true }
    user.stub(:courier) { courier }
    helper.stub(:courier_settings_set_path)
    helper.stub(:link_to)

    helper.should_receive(:image_tag).with('on.png')
    helper.courier_setting_link(user, template, service)
   end

  it "should return 'on' icon when is on" do
    courier = double :courier
    courier.should_receive(:disabled?) { false }
    courier.should_receive(:on?) { false }
    user.stub(:courier) { courier }
    helper.stub(:courier_settings_set_path)
    helper.stub(:link_to)

    helper.should_receive(:image_tag).with('off.png')
    helper.courier_setting_link(user, template, service)
   end

end
