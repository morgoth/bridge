class UserSession
  include ActiveModel::AttributeMethods
  include ActiveModel::Conversion
  include ActiveModel::Validations

  # ATTRIBUTES
  attr_reader :attributes

  attribute_method_suffix ""
  attribute_method_suffix "="

  define_attribute_methods [:email, :password, :id]

  # VALIDATION
  validates :email, :presence => true
  validates :password, :presence => true
  validate :authenticate

  def initialize(session, attributes = {})
    self.attributes = attributes
    @session = session
    @destroyed = false
  end

  def attributes=(attributes)
    @attributes = attributes.symbolize_keys.merge(:id => nil)
  end

  def new_record?
    id.nil?
  end

  def destroyed?
    @destroyed
  end

  def save
    if valid?
      self.id = @session[:user_id] = find_user_by_email.id
      true
    else
      false
    end
  end

  def destroy
    @session.delete(:user_id)
    @destroyed = true
  end

  def self.find(session)
    returning(new(session)) do |user_session|
      user_session.id = session.fetch(:user_id)
    end
  rescue IndexError
  end

  def user
    User.find_by_id(id)
  end

  protected

  def attribute(name)
    @attributes[name.to_sym]
  end

  def attribute=(name, value)
    @attributes[name.to_sym] = value
  end

  def authenticate
    user = find_user_by_email
    if user
      errors.add :password, "is invalid" unless user_authenticated?(user)
    else
      errors.add :email, "does not exist"
    end
  end

  def find_user_by_email
    User.find_by_email(email.strip.downcase) if email.present?
  end

  def user_authenticated?(user)
    user.authenticated?(password)
  end
end
