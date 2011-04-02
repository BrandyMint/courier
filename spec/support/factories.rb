#Factory.sequence(:email) { |n| "person#{n}@example.com" }
Factory.sequence(:service_name) { |n| "Service #{n}" }
Factory.sequence(:template_key) { |n| "template_#{n}" }
# Factory.sequence(:service_type) { |n| "Service::Type#{n}" }
# Factory.sequence(:contact_email) { |n| "contact#{n}@example.com" }
# Factory.sequence(:authentication_email) { |n| "auth#{n}@example.com" }
# Factory.sequence(:contact_name) { |n| "John #{n} Doe Contact" }
# Factory.sequence(:url) { |n| "http://localhost/#{n}" }
# Factory.sequence(:string) { |n| "string#{n}" }
# Factory.sequence(:token) { |n| "token#{n}" }
# Factory.sequence(:datetime) { |n| DateTime.now.ago(n.hours) }
# Factory.sequence(:date) { |n| DateTime.now.ago(n.days).to_date }
# Factory.sequence(:int) { |n| n }


Factory.define :user do |u|
  u.name 'Bob'
end

Factory.define :template, :class=>'Courier::Template::Base' do |f|
  f.key { Factory.next :template_key }
end

# Factory.define :owner_setting, :class=>'Courier::OwnerSetting' do |u|
#   u.owner {|c| c.association(:user)}
#   u.settings {}
# end
