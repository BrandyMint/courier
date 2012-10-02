# encoding: utf-8
class Courier::Mailer::Base < ActionMailer::Base

  attr_accessor :context

  # initialize может быть и с method_name=nil
  # но я пока непонимаю когда это может быть
  #
  def initialize(method_name, _context, *args)
    self.context = _context

    # мы знаем что super возвращает тоже что и содержит
    # метод message
    super( method_name, context, *args )
  end

  def mail(headers={}, &block)
    super get_headers(headers), &block
  end

  private

  def get_headers h={}
    h['X-Courier-SubscriptionList'] = context.subscription.subscription_list.name

    if context.subscription.present?
      h['X-Courier-Subscription-Id'] = context.subscription.id.to_s
    end

    h[:to] = context.to if context.to
    h[:from] = context.from if context.from
    h[:subject] = context.subject if context.subject

    h
  end

end
