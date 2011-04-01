# -*- coding: utf-8 -*-

# Индивидуальные настройки для каждого пользователя. Матрица пересечения сервис-шаблон для каждого владельца.


class Courier::OwnerSet < ActiveRecord::Base
  set_table_name 'courier_owner_sets'

  belongs_to :owner, :polymorphic=>true
  belongs_to :service, :class_name=>'Courier::Service::Base' #:polymorphic=>true
  belongs_to :template, :polymorphic=>true

  scope :enabled, where(:state=>:enabled)
  scope :by_template, lambda { |template| where(:template_id=>template.id) }

  validates_presence_of :owner, :service, :template
  validates_uniqueness_of :owner_id, :scope=>[:service_id, :template_id]


  state_machine :state, :initial => :enabled do
    state :disabled
    state :enabled
  end

  def message(*args)
    service.message(owner, template, *args) if enabled?
  end
end
