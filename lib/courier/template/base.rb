# -*- coding: utf-8 -*-
class Courier::Template::Base < ActiveRecord::Base
  set_table_name 'courier_templates'

  has_many :courier_owner_sets, :class_name=>"Courier::OwnerSet", :foreign_key=>:template_id, :dependent=>:destroy
  has_many :services, :through=>:courier_owner_sets

  validates_presence_of :key
  validates_uniqueness_of :key

  def get_text(args)
    args[:scope]=[:courier,:messages] unless args[:scope]
    I18n::translate(key, args )
  end
end
