class Courier::LogEntity < ActiveRecord::Base

  belongs_to :subscription, :class_name => 'Courier::Subscription'
  belongs_to :subscription_list, :class_name => 'Courier::SubscriptionList'
  belongs_to :user, :class_name => '::User'
  belongs_to :resource, :polymorphic => true
  belongs_to :restrict_object, :polymorphic => true

  validates :to, :presence => true
  validates :from, :presence => true
  validates :subject, :presence => true

  # validates :subscriber, :presence => true
  validates :subscription_list, :presence => true

  # Проекрка на уникальность делается по ключу
  # [:subscription_id, :object_type, :object_id, :to]
  validates :subscription_id,
    :uniqueness => { :scope => [:to, :restrict_object_type, :restrict_object_id] },
    :if => lambda { |r| r.restrict_object.present? }


  delegate :name, :to => :subscription, :prefix => true

  def self.save_mail mail, context
    user = context.user || context.subscription.try(:user)

    context.subscription.subscription_list.log_entities.create! :subscription => context.subscription,
      :resource => context.resource,
      :restrict_object => context.object,
      :user => user,

      :to => mail.to.first,
      :from => mail.from.first,
      :subject => mail.subject,
      :body => mail.body.to_s,

      # TODO mysql падает на больших размерах поля (700k)
      # поэтому просто возвращаем длинну
      :message => mail.to_s.length
  end
end
