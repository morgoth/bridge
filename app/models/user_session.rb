class UserSession
  include ActiveModel::AttributeMethods
  include ActiveModel::Conversion
  include ActiveModel::Validations

  # ATTRIBUTES
  attr_reader :errors, :attributes

  attribute_method_suffix ""
  attribute_method_suffix "="

  define_attribute_methods [:email, :password, :id]

  # VALIDATION
  validates :email, :presence => true
  validates :password, :presence => true
  validate :authenticate

  def initialize(session, attributes = {})
    @errors = ActiveModel::Errors.new(self)
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
      self.id = @session[:user_id] = user.id
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
    id = session[:user_id]
    self.class.new(session, :id => id) if id
  end

  def user
    if id.present?
      User.find_by_id(id)
    else
      user = find_user_by_email
      user_authenticated?(user) ? user : nil
    end
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
    User.find_by_email(email)
  end

  def user_authenticated?(user)
    user.authenticated?(password)
  end
end
