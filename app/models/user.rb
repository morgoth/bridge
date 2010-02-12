class User < ActiveRecord::Base
  validates_uniqueness_of :email
  validates_with EmailValidator

  attr_accessor :password

  validates :password, :presence => true, :confirmation => true, :length => 6..40, :if => :password_required?
  validates :password_confirmation, :presence => true, :if => :password_required?

  before_save :encrypt_password

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  private

  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def self.make_token
    secure_digest(Time.now, 10.times.map { rand.to_s })
  end

  def self.password_digest(password, password_salt)
    digest = ""
    10.times { digest = secure_digest(digest, password_salt, password) }
    digest
  end

  def encrypt(password)
    self.class.password_digest(password, password_salt)
  end

  def encrypt_password
    return if password.blank?
    self.password_salt    = self.class.make_token if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    crypted_password.blank? or password.present?
  end
end
