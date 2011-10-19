class Web::Session
  extend ActiveSession

  authenticates :user, :primary_key => "email", :foreign_key => "email"

  define_attribute_methods %w[password]
  attr_accessible :email, :password

  validates :email, :presence => true
  validates :password, :presence => true
  validate :authenticity

  private

  def authenticity
    errors.add :base, "bad credentials" unless user.try(:web_account).try(:authenticate, password)
  end
end
