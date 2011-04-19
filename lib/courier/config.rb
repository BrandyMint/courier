# -*- coding: utf-8 -*-

class Courier::Config
  attr_accessor :services_hash, :templates_hash, :services_order, :templates_order

  def initialize
    self.services_order=[]
    self.services_hash={}
    self.templates_order=[]
    self.templates_hash={}
  end

  def templates
    templates_order
  end

  def services *services
    return services_order if services.empty?
    raise 'Список сервисов уже определен' unless services_order.empty?

    self.services_order = services.map { |s|
      service = class_of_service(s).new
      services_hash[service.name] = service
    }
  end

  def get_service name
    name=name.to_sym
    services_hash[name] or raise "No such service '#{name}'. Specify it by Courier.init in ./config/initializers/courier.rb"
  end

  def template name, *sets
    raise "Values (#{sets.count}) and services counts (#{services_order.count}) not much" unless services_order.count==sets.count
    template = Courier::Template::Base.new(:name=>name)
    raise "Such template is already defined #{name}" if templates_hash.has_key? template.name
    sets.each_with_index do |val, index|
      service = services_order[index] or "Too many values (#{index}), no such services"
      template.set(service, val)
    end
    templates_order << template
    templates_hash[template.name] = template
  end

  def get_template key
    templates_hash[key.to_sym] or raise "No such template '#{key}'. Specify it by Courier.init in ./config/initializers/courier.rb"
  end

  def class_of_service(name)
    if name.is_a? Symbol
      "Courier::Service::#{name.to_s.classify}".constantize
    else
      name
    end
  end
end
