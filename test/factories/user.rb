Factory.define :user do |f|
  f.email { Factory.next(:email) }
  f.password "secret"
  f.password_confirmation { |u| u.password }
end
