# -*- coding: utf-8 -*-
require 'spec_helper'

describe GritterNotices::ViewHelpers, :type => :helper  do
  before do
    @user = Factory :user
    helper.stub!(:current_user) { @user }
  end

  let(:current_user) { @user }
  # let(:flash) { {:success=>'Success',:error=>['Error1','Error2']} }

  describe '#gritter_flash_messages' do
    it 'safe run with not current_user defined' do
      helper.unstub :current_user
      expect { helper.gritter_flash_messages }.should_not raise_error
    end

    it 'does not run js() if there it no gritters' do
      helper.should_not_receive(:js)
      helper.gritter_flash_messages
    end

    it 'collects flashes and users notices and run js()' do

      flash[:error]='Error'
      flash[:success]=['Success1','Success2']
      flash[:info]=nil
      current_user.notice :progress
      current_user.notice_warning 'Warning'

      compiled_gritters = [
        "$.gritter.add({image:'/images/gritter/error.png',title:'translation missing: en.gflash.titles.error',text:'Error'});",
        "$.gritter.add({image:'/images/gritter/success.png',title:'translation missing: en.gflash.titles.success',text:'Success1'});",
        "$.gritter.add({image:'/images/gritter/success.png',title:'translation missing: en.gflash.titles.success',text:'Success2'});",
        "$.gritter.add({image:'/images/gritter/progress.png',title:'translation missing: en.gflash.titles.progress',text:'translation missing: en.gritter_notices.progress'});",
        "$.gritter.add({image:'/images/gritter/warning.png',title:'translation missing: en.gflash.titles.warning',text:'Warning'});"]
      helper.should_receive(:js).with(compiled_gritters) { mock :html_safe=>true }
      helper.gritter_flash_messages
    end
  end

  describe '#move_gritter_notices_to_flashes' do
    specify do
      notice = mock :level=>:level, :message=>:message
      notice.should_receive(:mark_as_delivered).twice
      current_user.stub_chain('gritter_notices.fresh') {[notice,notice]}
      helper.should_receive(:append_flash_message).twice
      helper.move_gritter_notices_to_flashes
    end
  end
end
