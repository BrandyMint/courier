# -*- coding: utf-8 -*-

# Индивидуальные настройки для каждого пользователя. Матрица пересечения сервис-шаблон для каждого владельца.


class Courier::OwnerSetting < ActiveRecord::Base
  set_table_name 'courier_owner_setting'

  belongs_to :owner, :polymorphic=>true

  serialize :settings, Hash

  before_validation do
    self.settings||={}
  end

  validates_presence_of :owner
  validates_uniqueness_of :owner_id, :scope=>:owner_type

  def settings_of_template(template)
    template = Courier.template(template) if template.is_a? Symbol
    settings[template.name]||={}
  end

  def set(template, service, val=nil)
    service = Courier.service(service) if service.is_a? Symbol
    raise 'Cant use value as argument when block given' if block_given? and val
    settings_of_template(template)[service.name] = block_given? ? yield : val
  end

  def get(template, service)
    service = Courier.service(service) if service.is_a? Symbol
    template = Courier.template(template) if template.is_a? Symbol
    val = settings_of_template(template)[service.name]
    val || template.get(service)
  end

  def enabled?(template, service, args={})
    get(template, service)==:on
  end

  def disabled?(template, service, args={})
    get(template, service)==:off
  end
end
