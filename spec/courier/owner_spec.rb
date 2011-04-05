# -*- coding: utf-8 -*-
require 'spec_helper'

describe User, "Courier::Owner extention" do

  it { should have_one(:courier).dependent(:destroy) }

  describe 'creates courier automatically' do
    subject{ Factory :user }
    its(:courier) { should be_kind_of(Courier::OwnerSetting) }
  end

  describe '#message' do
    let(:args) { {:level=>123, :text=>'some text'} }
    subject{ Factory :user }
    it 'should send message to turned on services only' do
      template = mock_template

      service1 = mock_service
      service2 = mock_service
      service1.should_receive(:message).with(subject, template, args)

      subject.should_not_receive :create_courier

      subject.courier.should_receive(:on?).twice { |template, service, args|
        service==service1
      }

      Courier.should_receive(:config) { double :services_order=>[service1, service2] }
      Courier.should_receive(:template).with(:templ) { template }
      subject.message :templ, args
    end
  end
end
