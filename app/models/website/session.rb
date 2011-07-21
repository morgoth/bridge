class Website::Session
  extend ActiveModel::Naming
  include ActiveModel::AttributeMethods
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Validations

  attribute_method_suffix "", "="
  define_attribute_methods %w[email password account_id]
  attr_accessible :email, :password

  attr_reader :attributes

  validates :email, :presence => true, :unless => :account
  validates :password, :presence => true, :unless => :account
  validate :authenticity

  def self.store_key
    model_name.singular.to_sym
  end

  def self.find(store)
    account_id = store[store_key] && store[store_key][:account_id]
    return if account_id.blank?
    account = Website::Account.find_for_authentication(:id => account_id)
    return if account.blank?
    new(store) { |session| session.account = account }
  end

  def initialize(store, attributes = {})
    @store = store
    @attributes = {}
    self.attributes = attributes
    yield self if block_given?
  end

  def attributes=(attributes)
    sanitize_for_mass_assignment(attributes).each { |key, value| send("#{key}=", value) }
  end

  def save
    valid? && serialize && true
  end

  def account
    Website::Account.where(:id => account_id).first
  end

  def account=(account)
    self.account_id = account.id
  end

  def persisted?
    account_id.present? and @store[self.class.store_key].present? and @store[self.class.store_key][:account_id] == account_id
  end

  def destroy
    persisted? && @store.delete(self.class.store_key) && true
  end

  private

  def attribute(attribute)
    @attributes[attribute.to_sym]
  end

  def attribute=(attribute, value)
    @attributes[attribute.to_sym] = value
  end

  def serialize
    @store[self.class.store_key] = {:account_id => account_id}
  end

  def authenticity
    return if email.blank? or password.blank?
    account = Website::Account.find_for_authentication(:email => email)
    errors.add :email, :invalid if account.blank?
    return if account.blank?
    authenticated_account = account.authenticate(password)
    errors.add :password, :invalid if account.present? if not authenticated_account
    return if not authenticated_account
    self.account = account
  end
end
