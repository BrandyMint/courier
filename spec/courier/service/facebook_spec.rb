# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::Service::Facebook do
  describe '#deliver!' do
    it 'posts messages with Koala' do
      owner = mock_owner :facebook_token=>'fbtoken'

      message = mock_message :owner=>owner, :options=>{:text=>'text'}
      message.should_receive(:mark_as_delivered!)

      graph = double
      graph.should_receive(:put_object).
        with('me','feed',{:message=>'text'}) { true }
      Koala::Facebook::GraphAPI.should_receive(:new).with('fbtoken') { graph }

      subject.stub_chain('messages.fresh') { [message] }
      subject.deliver_all!
    end
  end
end
