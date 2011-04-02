# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier do
  specify { ActiveRecord::Base.should respond_to(:has_courier)}

  describe '.init' do
    specify do
      should_receive(:some_stub)
      Courier.init do
        some_stub
      end
    end
  end

  describe '.deliver_all!' do
    it 'should run deliver! for all services' do
      service = mock_service
      service.should_receive(:deliver!).twice
      Courier.config.should_receive(:services) { [service, service]}
      Courier.deliver_all!
    end
  end

end
