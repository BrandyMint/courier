# -*- coding: utf-8 -*-
require 'spec_helper'

describe User, "Courier::Owner extention" do

  it { should have_many(:courier_owner_sets).dependent(:destroy) }
  it { should have_many(:courier_enabled_services) }


  def clear_stuff
    Courier::Service::Base.destroy_all
    Courier::Template::Base.destroy_all
  end

  def register_stuff
    clear_stuff
    Courier.register_services(Courier::Service::ActiveMailer, Courier::Service::GritterNotices)
    Courier.register_templates(:system_notify, :import_complete, :avatar_loaded)
  end

  describe '.courier_bootstrap_all!' do
    it 'should bootstrap all owners' do
      o = double()
      o.should_receive :courier_bootstrap!
      User.should_receive(:all) { [o] }
      User.courier_bootstrap_all!
    end
  end


  describe '#courier_enabled_services' do
    before do
      Factory :service_email
    end
  end

  describe '#message' do
    let(:args) { {:level=>123,:text=>'some text'} }
    it 'should send message to all enabled services for selected template' do
      template = mock_template

      set = mock_sets
      set.should_receive(:message).with(args).twice
      subject.courier_owner_sets.should_receive(:by_template).with(template) { mock :enabled=>[set, set] }

      Courier.should_receive(:template).with(:templ) { template }
      subject.message :templ, args
    end
  end

  describe '#courier_bootstrap!' do
    describe 'bootstraps at creation' do
      before(:all) do
        register_stuff
        @owner = Factory :user
        # @owner.courier_bootstrap!
      end
      subject {@owner}
      its(:courier_owner_sets) { should have(6).items }
      after(:all) do
        # @owner.destroy
        clear_stuff
      end
    end
  end
end
