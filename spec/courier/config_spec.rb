require 'spec_helper'

describe Courier::Config do
  before do
    subject.services :active_mailer, :facebook
  end

  describe '#services' do
    it 'initialize services by name and preserve order' do
      subject.services.first.should be_kind_of(Courier::Service::ActiveMailer)
      subject.services.last.should be_kind_of(Courier::Service::Facebook)
    end

    it 'return ordered list of services when called with not args' do
      services=[1,2,3]
      subject.should_receive(:services_order) { services }
      subject.services.should == services
    end
  end

  describe '#get_service'

  describe '#template' do
    it 'sets default values for template' do
      subject.template :import_complete, :on, :off
      subject.get_template(:import_complete).should be_kind_of(Courier::Template::Base)
    end

    it 'raise errors when services counts not much' do
      expect { subject.template :import_complete, :on, :off, :off }.to raise_error
    end

    it 'raise errors when value unknown' do
      expect { subject.template :import_complete, :on, :bad_value }.to raise_error
    end
  end
end
