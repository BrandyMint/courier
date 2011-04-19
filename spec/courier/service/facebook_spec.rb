# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::Service::Facebook do
  describe '#deliver!' do
    before do
      @owner = mock_owner :facebook_id=>123
    end
    let(:owner) { @owner }
    let(:message) { mock_message :owner=>owner, :options=>{:text=>'text'} }

    it 'posts messages with Koala' do
      owner.stub(:facebook_token) { 'fbtoken' }

      message.should_receive(:mark_as_delivered!)

      graph = double
      graph.should_receive(:put_object).with(123,'feed',{:message=>'text'}) { true }
      Koala::Facebook::GraphAPI.should_receive(:new).with('fbtoken') { graph }

      subject.stub_chain('messages.fresh') { [message] }
      subject.deliver_all!
    end

    it 'do nothing if there is no token' do
      Koala::Facebook::GraphAPI.should_not_receive(:new)

      subject.stub_chain('messages.fresh') { [message] }
      subject.deliver_all!
    end
  end
end
