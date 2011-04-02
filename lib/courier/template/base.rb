# -*- coding: utf-8 -*-
class Courier::Template::Base

  attr_accessor :name, :defaults

  def initialize(args)
    self.name = args[:name].to_sym or raise 'no template name defined'
    self.defaults={}
  end

  def get_text(args)
    args[:scope]=[:courier,:messages,args[:service].name] unless args[:scope]
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

  def key
    name
  end

  private

  def check_val(val)
    raise "Value must be :on or :off" unless val==:on or val==:off
    val
  end


end
