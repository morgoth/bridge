Factory.define :user do |f|
  f.email { Factory.next(:email) }
  f.sequence(:display_name) { |n| "person_#{n}" }
  f.password "secret"
  f.password_confirmation { |u| u.password }
end
