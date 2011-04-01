# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::Template::Base do
  it { should have_many(:courier_owner_sets)}
  it { should have_many(:services)}
  it { should validate_presence_of(:key) }

  context 'created' do
    before do
      Factory :template
    end
    it { should validate_uniqueness_of(:key) }
  end

  context '#get_text' do
    it 'should return text with localized tranlation' do
      subject.should_receive(:key) { 'template_key' }
      subject.get_text(:some_option=>123).should == 'translation missing: en.courier.messages.template_key'
    end
  end

  # context '#sets_by_owner' do
  #   let(:owner) { Factory :user }
  #   it do
  #     subject.sets_by_owner(owner)
  #   end
  # end
end
