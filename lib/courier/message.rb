# -*- coding: utf-8 -*-


# Моделька в помощь тем сервисам, что хотят иметь сохраненные сообщения для последующей доставки

class Courier::Message < ActiveRecord::Base
  set_table_name 'courier_messages'

  belongs_to :owner, :polymorphic=>true

  serialize :options, Hash

  scope :fresh, where(:state=>:fresh)
  scope :by_service, lambda { |service| where(:service=>service.to_s) }

  validates_presence_of :owner, :service, :template

  state_machine :state, :initial => :fresh do
    state :fresh
    state :delivered
    event :set_delivered do
      transition :fresh => :delivered
    end
  end
end
