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

Factory.define :service, :class=>'Courier::Service::Base' do |f|
  f.type 'Courier::Service::Base'
end

Factory.define :next_service, :parent=>:service do |f|
  f.name { Factory.next :service_name }
end

Factory.define :action_mailer_service, :class=>'Courier::Service::Email::ActionMailer', :parent=>:service do

end

Factory.define :template, :class=>'Courier::Template::Base' do |f|
  f.key { Factory.next :template_key }
end

Factory.define :owner_set, :class=>'Courier::OwnerSet' do |u|
  u.owner {|c| c.association(:user)}
  u.service {|c| c.association(:next_service) }
  u.template {|c| c.association(:template) }
end

