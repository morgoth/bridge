class Web::Account < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :email

  has_secure_password

  def self.find_for_authentication(conditions)
    where(conditions).first
  end
end
