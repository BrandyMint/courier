# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::Service::Base do
  it { should have_many(:courier_owner_sets)}

  # Устанавливаются автомтачески
  # it { should validate_presence_of(:name) }
  it { should validate_presence_of(:type) }

  # it { should respond_to(:enabled_for_owner) }

  context 'created' do
    before do
      @service = Factory :service
    end
    subject {@service}
    it { should validate_uniqueness_of(:name) }

    its(:name) { should == 'Base' }


    after do
      @service.destroy
    end
  end


  describe '#message' do
    it 'saves message in database' do
      args={:a=>1}
      owner = double
      template = double
      cm = double
      cm.should_receive(:create!).with(:owner=>owner, :template=>template, :options=>args)
      subject.should_receive(:courier_messages) { cm }
      subject.message owner, template, args
    end
  end

  describe '#deliver!' do
  end


  describe 'uses last subclass as name' do
    before do
      module Courier::Service::SMS end
      class Courier::Service::SMS::SuperGateway < Courier::Service::Base;  end
    end
    subject {Courier::Service::SMS::SuperGateway.create}
    its(:name) { should == 'SuperGateway' }
  end
end
