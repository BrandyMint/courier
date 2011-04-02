# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::Service::Base do
  its(:name) { should == :base }

  describe '#message' do
    it 'saves message in database' do
      args={:a=>1}
      owner = double
      template = double
      cm = double
      cm.should_receive(:create!).with(:owner=>owner, :template=>template, :options=>args)
      subject.should_receive(:courier_messages) { cm }
      subject.should_receive(:check_args).with(owner, template, args)
      subject.message owner, template, args
    end
  end

  # inherited in subclasses
  describe '#deliver!'

  describe 'last subclass title as name' do
    before do
      class Courier::Service::SuperGateway < Courier::Service::Base;  end
    end
    subject { Courier::Service::SuperGateway.new }
    its(:name) { should == :super_gateway }
  end

  describe 'class-level configuration' do
    before do
      class Courier::Service::SuperGateway < Courier::Service::Base;  end
      class Courier::Service::SuperGateway2 < Courier::Service::Base;  end
      Courier::Service::SuperGateway.configure do |config|
        config.test=123
      end
      Courier::Service::SuperGateway2.configure do |config|
        config.test=456
      end
    end

    specify 'lets configure' do
      Courier::Service::SuperGateway.config.test.should == 123
      Courier::Service::SuperGateway2.config.test.should == 456
    end
  end
end
