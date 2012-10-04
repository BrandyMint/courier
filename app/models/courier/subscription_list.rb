class Courier::SubscriptionList < ActiveRecord::Base
  has_many :log_entities, :foreign_key => :subscription_list_id, :class_name => 'LogEntity'
  has_many :subscriptions, :foreign_key=>:subscription_list_id, :class_name => 'Subscription',
           :dependent => :destroy

  belongs_to :subscription_type, :class_name => 'SubscriptionType::Base'

  def subscribe user, resource = nil
    s = get_subscription user, resource
    if s
      s.activate unless s.active?
      s
    else
      subscriptions.create(user: user, resource: resource)
    end
  end

  def unsubscribe user, resource = nil
    s = get_subscription user, resource
    s.deactivate
  end

  def collect_subscriptions resource=nil, params={}
    list = subscriptions.by_resource resource
    list = list.exclude_users params[:exclude_users].compact if params[:exclude_users]
    list
  end

  def get_subscription user, resource = nil
    subscriptions.by_resource(resource).where(user_id: user.id).first
  end
end
