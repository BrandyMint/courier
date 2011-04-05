# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::OwnerSetting do

  it { should belong_to(:owner) }
  it { should validate_presence_of(:owner) }

  context 'created' do
    before do
      @user = Factory :user
      @service = mock_service :id=>2, :name=>'service1'
      @template = mock_template :get=>:tralala, :name=>:template_key
      Courier.stub(:service) { @service }
      Courier.stub(:template) { @template }
    end

    subject { @user.courier }
    # let(:template) { @template }
    let(:template_key) { :template_key }
    let(:service) { @service }

    describe '#set and #get' do
      it 'use default if no set' do
        subject.get(template_key, service).should == :tralala
      end

      context 'get on disabled' do
        before do
          @template.stub(:get) { :disabled }
          subject.set(template_key, service, :on)
        end
        it{ subject.get(template_key, service).should == :disabled }
        it { subject.on?(template_key, service).should be_false }
      end

      context 'set to nil' do
        before do
          subject.set(template_key, service, nil)
        end
        specify 'remove service' do
          subject.settings[:template_key].should_not include(service.name)
        end
        it 'uses default' do
          subject.get(template_key, service).should == :tralala
        end
        it { subject.on?(template_key, service).should be_false }
      end

      context ':on as block' do
        before do
          subject.set(template_key, service) { :on }
        end
        it { subject.get(template_key, service).should == :on }
        it { subject.on?(template_key, service).should be_true }
      end

      context ':off as argument' do
        before do
          subject.set(template_key, service, :off)
        end
        it { subject.get(template_key, service).should == :off }
        it { subject.off?(template_key, service).should be_true }
        it { subject.on?(template_key, service).should be_false }
      end
    end
  end
end
