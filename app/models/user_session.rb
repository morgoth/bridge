class UserSession
  extend ActiveModel::Naming
  include ActiveModel::AttributeMethods
  include ActiveModel::Validations

  attr_reader :errors
  attr_accessor :attributes

  attribute_method_suffix ""
  attribute_method_suffix "="

  define_attribute_methods [:email, :password, :id]

  validates :email, :presence => true
  validates :password, :presence => true

  validate :authenticate

  def initialize(attributes = {})
    @errors = ActiveModel::Errors.new(self)
    @attributes = attributes
  end

  def new_record?
    true
  end

  protected

  def attribute(name)
    @attributes[name.to_sym]
  end

  def attribute=(name, value)
    @attributes[name.to_sym] = value
  end

  def authenticate
    user = User.find_by_email(email)
    if user
      errors.add :password, "is invalid" unless user.authenticated?(password)
    else
      errors.add :email, "does not exist"
    end
  end
end
