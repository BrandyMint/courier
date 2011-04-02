# -*- coding: utf-8 -*-
require 'spec_helper'

describe Courier::Service::GritterNotice do
  describe '#message' do
    it 'send message to gritter_notice' do
      args={:a=>1}
      owner = double
      template = double :name=>:template_key
      I18n.should_receive(:translate).with(template.name, :scope=>[:courier, :gritter_notice]) {{:text=>'text of translation', :level=>:warning} }
      owner.should_receive(:gritter_notice).with(template.name, {:text=>"text of translation", :a=>1, :level=>:warning})
      subject.message owner, template, args
    end
  end

  describe '#deliver!' do
    it 'do nothing' do
      subject.deliver!
    end
  end
end
