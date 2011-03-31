module Courier::ActiveRecord
  def has_courier
    has_many :courier_users_settings, :as => :owner, :dependent => :destroy_all
    include InstanceMethods
  end

  module InstanceMethods

    def courier
      @courier ||= Courier::OwnersObject.new(self)
    end

    def method_missing2(method_name, *args, &block)
      if level = ValidMethods[method_name]
        options = args.extract_options!
        options[:level] = level
        args << options
        notice *args
      else
        super(method_name, *args, &block)
      end
    end
  end
end
