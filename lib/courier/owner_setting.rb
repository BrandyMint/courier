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
    template = Courier.template(template)
    settings[template.name]||={}
  end

  def set(template, service, val=nil)
    service = Courier.service(service)
    raise 'Cant use value as argument when block given' if block_given? and val
    val = yield if block_given?
    if val.blank?
      settings_of_template(template).delete(service.name)
      nil
    else
      # TODO validate setted value
      settings_of_template(template)[service.name] = val.to_sym
    end
  end

  def set!(template, service, val=nil)
    if block_given?
      set template, service do
        yield
      end
    else
      set(template, service, val)
    end
    save!
  end


  def get(template, service)
    service = Courier.service(service)
    template = Courier.template(template)
    default = template.get(service)
    return :disabled if default==:disabled
    val = settings_of_template(template)[service.name]
    val || default
  end

  def on?(template, service, args={})
    get(template, service)==:on
  end

  def off?(template, service, args={})
    get(template, service)==:off
  end

  def disabled?(template, service, args={})
    get(template, service)==:disabled
  end

  # def enabled?(template, service, args={})
  #   get(template, service)!=:disabled
  # end
end
