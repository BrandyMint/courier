# -*- coding: utf-8 -*-
class CreateCourierTables < ActiveRecord::Migration
  def self.up
    create_table :courier_owner_setting, :force => true do |t|
      t.integer  :owner_id,                           :null => false
      t.string   :owner_type,                         :null => false
      t.text     :settings,                           :null => false
      t.timestamps
    end

    add_index :courier_owner_setting, [:owner_id, :owner_type], :unique=>true

    # create_table :courier_templates, :force => true do |t|
    #   t.string   :key,                         :null => false, :unique=>true
    #   t.text     :settings,                    :null => false
    #   t.timestamps
    # end

    create_table :courier_messages, :force => true do |t|
      t.integer   :owner_id,                           :null => false
      t.string    :owner_type,                         :null => false
      t.string    :template,                           :null => false
      t.string    :service,                            :null => false
      t.string    :state,                              :null => false
      t.text      :options,                            :null => false
      t.timestamp :delivered_at
      t.timestamps
    end

    add_index :courier_messages, [:service, :state]
  end

  def self.down
    # drop_table :gritter_notices
  end
end
