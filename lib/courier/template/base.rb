# -*- coding: utf-8 -*-
class Courier::Template::Base

  AvailableValues = [:on, :off, :disabled]

  attr_accessor :name, :defaults

  def initialize(args)
    self.name = args[:name].to_sym or raise 'no template name defined'
    self.defaults={}
  end

  def get_text(service, args)
    args[:scope]=[:courier, :services, service.to_s, :templates] unless args[:scope]
    args[:cascade]=true unless args.has_key? :cascade
    I18n::translate(name, args )
  end

  def get(service)
    service = Courier.service(service) if service.is_a?(Symbol)
    name = service.name.to_sym
    raise "Not defined default value for #{service} in template #{self}" unless defaults.has_key? name
    defaults[name]
  end

  def set(service, val)
    service = Courier.service(service) if service.is_a?(Symbol)
    defaults[service.name.to_sym] = check_val(val)
  end

  def to_s
    name.to_s
  end

  def to_label
    I18n::translate(name, :scope=>[:courier,:templates] )
  end

  def key
    name
  end

  private

  def check_val(val)
    raise "Value must be one of  #{AvailableValues.join(', ')}" unless AvailableValues.include? val
    val
  end


end
