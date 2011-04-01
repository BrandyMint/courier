# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier do
  specify { ActiveRecord::Base.should respond_to(:has_courier)}

  describe '.template' do
    it 'should find template by given name' do
      Courier::Template::Base.should_receive(:find_by_key).with('templ_name') { true }
      subject.template('templ_name')
    end
    it 'should raise when no template found' do
      expect { subject.template('not_existen_template') }.to raise_error(RuntimeError, "No such template 'not_existen_template' found")
    end
  end

  describe '.templates' do
    specify {
      Courier::Template::Base.should_receive(:all)
      Courier.templates
    }
  end

  describe '.register_templates' do
    before(:all) do
      Courier.register_templates :import_complete, :avatar_loaded
    end
    its(:templates) { should have(2).items }
    it { Courier.templates.last.key.should == 'avatar_loaded' }
    after(:all) do
      Courier::Template::Base.destroy_all
    end
  end

  describe '.register_services' do
    before(:all) do
      Courier.register_services Courier::Service::ActiveMailer, Courier::Service::GritterNotices
    end
    subject { Courier::Service::Base.find_by_name('ActiveMailer') }
    it { should be_a(Courier::Service::ActiveMailer) }
    its(:name) { should == 'ActiveMailer' }

    describe '.services' do
      specify {
        Courier.services.should include(subject)
      }
      it { Courier.services.should have(2).items }
    end

    after(:all) do
      subject.delete
    end
  end


  describe '.deliver_all!' do
    it 'should run deliver! for all services' do
      service = mock_service
      service.should_receive(:deliver!).twice
      Courier.should_receive(:services) { [service, service]}
      Courier.deliver_all!
    end
  end
end
