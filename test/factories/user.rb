Factory.define :user do |u|
  u.email { Factory.next(:email) }
  u.password "secret"
  u.password_confirmation "secret"
end
