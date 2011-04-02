# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::Template::Base do

  subject { described_class.new(:name=>:template_key)}

  its(:name) { should == :template_key }

  context '#get_text' do
    it 'should return text with localized tranlation' do
      subject.should_receive(:name) { 'template_key' }
      subject.
        get_text(mock_service(:to_s=>'facebook'), :some_option=>123).should ==
        'translation missing: en.courier.facebook.template_key'
    end
  end

  # context '#sets_by_owner' do
  #   let(:owner) { Factory :user }
  #   it do
  #     subject.sets_by_owner(owner)
  #   end
  # end
end
