# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::OwnerSet do

  it { should belong_to(:owner) }
  it { should belong_to(:template) }
  it { should belong_to(:service) }

  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:service) }
  it { should validate_presence_of(:template) }

  describe 'scopes' do
    subject {Courier::OwnerSet}
    it { subject.by_template(mock_model Courier::Template::Base).should be_empty }
    its(:enabled) { should be_empty }
  end

  describe '#message' do
    subject { Factory :owner_set }

    context 'enabled' do
      it {should be_enabled }
      it 'send message to service with owner, template and arguments' do
        args={:a=>1}
        template = mock_template

        service = mock_service
        service.should_receive(:message).with(subject.owner, template, args)

        subject.should_receive(:template) { template }
        subject.should_receive(:service) { service }
        subject.message(args)
      end
    end

    context 'disabled' do
      it 'should not send message' do
        subject.should_receive(:enabled?) { false }
        subject.should_not_receive(:service)
        subject.message()
      end
    end
  end

  after(:all) do
    # Че оно само не чистится, не понял
    Courier::Service::Base.destroy_all
    Courier::Template::Base.destroy_all
  end
end
