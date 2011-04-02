# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::OwnerSetting do

  it { should belong_to(:owner) }
  it { should validate_presence_of(:owner) }

  context 'created' do
    before do
      @user = Factory :user
      Courier.stub(:template) { mock_template :get=>:tralala, :name=>:template_key }
    end

    subject { @user.courier }
    # let(:template) { @template }
    let(:template_key) { :template_key }
    let(:service) { mock_service :id=>2, :name=>'service1' }

    describe '#set and #get' do
      it 'use default if no set' do
        subject.get(template_key, service).should == :tralala
      end

      context ':on as block' do
        before do
          subject.set(template_key, service) { :on }
        end
        it { subject.get(template_key, service).should == :on }
        it { subject.enabled?(template_key, service).should be_true }
      end

      context ':off as argument' do
        before do
          subject.set(template_key, service, :off)
        end
        it { subject.get(template_key, service).should == :off }
        it { subject.disabled?(template_key, service).should be_true }
        it { subject.enabled?(template_key, service).should be_false }
      end
    end
  end
end
