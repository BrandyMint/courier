# -*- coding: utf-8 -*-
class CreateCourierTables < ActiveRecord::Migration
  def self.up
    create_table :courier_owner_sets, :force => true do |t|
      t.integer  :owner_id,                           :null => false
      t.string   :owner_type,                         :null => false
      t.integer  :template_id,                :null => false
      t.integer  :service_id,                 :null => false
      t.string   :state,                              :null=>false
      t.timestamps
    end

    add_index :courier_owner_sets, [:owner_id, :template_id, :service_id], :unique=>true, :name=>:courier_owner_sets_unique

    create_table :courier_services, :force => true do |t|
      t.string   :type,                         :null => false, :unique=>true
      t.string   :name,                         :null => false, :unique=>true
      t.timestamps
    end

    create_table :courier_templates, :force => true do |t|
      t.string   :key,                         :null => false, :unique=>true
      t.timestamps
    end

    create_table :courier_messages, :force => true do |t|
      t.integer  :owner_id,                           :null => false
      t.string   :owner_type,                         :null => false
      t.integer  :template_id,                        :null => false
      t.integer  :service_id,                         :null => false
      t.string   :state,                              :null => false
      t.text     :options,                            :null => false
      t.timestamp :delivered_at
      t.timestamps
    end

    add_index :courier_messages, [:service_id, :state]
  end

  def self.down
    # drop_table :gritter_notices
  end
end
