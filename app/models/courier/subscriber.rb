# -*- coding: utf-8 -*-
class Courier::Subscriber < ActiveRecord::Base
  # set_table_name :courier_subscribers

  belongs_to :user
  belongs_to :subscription, :class_name => 'Courier::Subscription::Base'

  belongs_to :resource, :polymorphic => true

  scope :active, where(is_active: true)

  scope :by_resource, lambda { |resource|
    conditions = resource ? { :resource_id => nil } : { :resource_id => resource.id, :resource_type => resource.class.base_class.model_name}
    active.where(conditions)
  }

  scope :without_users, lambda{ |users|
    where("user_id not in (?)", users.map(&:id))
  }

  scope :by_subscription, lambda{ |subscription| where(subscription_id: subscription.id)}

  validates :user, :presence => true
  validates :subscription, :presence => true
  validates :token, presence: true, uniqueness: true

  validates :subscription_id, :uniqueness => {:scope => [:user_id, :resource_id, :resource_type]}

  delegate :to_s, :to_label, :email, :to => :user
  delegate :description, :access, :to => :subscription

  before_validation :generate_token

  def active?
    persisted? and is_active
  end

  def to
    user.email_to
  end

  def activate
    update_attribute :is_active, true
  end

  def deactivate
    if subscription.sticky
      update_attribute :is_active, false
    else
      destroy
    end
  end

  def title
    return description unless resource

    [description, resource_title].join ' '
  end

  def resource_title
    # Подписка без ресурса
    return '' unless resource.present?

    courier_resource_title = self.resource.class.instance_variable_get(:@courier_resource_title)

    if courier_resource_title
      if courier_resource_title.is_a?(Proc)
        resource.instance_exec(&courier_resource_title)
      else
        resource.send(courier_resource_title)
      end
    else
      "#{resource.class}##{resource.id}"
    end
  end

  def resource_url
    return nil unless resource
    if resource.respond_to? :url
    else
      polymorphic_url resource
    end
  end

  protected

  def generate_token
    return if self.token and !self.token.blank?

    token = Blogs::Utils.generate_token(20)
    unless Courier::Subscriber.find_by_token(token)
      self.token = token
    end
  end

end
