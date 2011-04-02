# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::Service::Facebook do
  describe '#deliver!' do
    it 'posts messages with Koala' do
      owner = mock_owner :facebook_token=>'fbtoken'

      message = mock_message :owner=>owner, :options=>{:text=>'text',:attachment=>{},:to=>'123'}
      message.should_receive(:owner)
      message.should_receive(:set_delivered)

      graph = double
      graph.should_receive(:put_wall_post).
        with(message.options[:text], message.options[:attachment], message.options[:to]) { true }
      Koala::Facebook::GraphAPI.should_receive(:new).with('fbtoken') { graph }

      subject.stub_chain('courier_messages.fresh') { [message] }
      subject.deliver!
    end
  end
end
