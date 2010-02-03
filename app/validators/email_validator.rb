class EmailValidator < ActiveModel::Validator
  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\Z/i

  def validate(record)
    record.errors[email_field] << :invalid unless email_valid?(record[email_field])
  end

  protected

  def email_field
    options.fetch(:attribute, :email)
  end

  def email_valid?(email)
    email =~ EMAIL_REGEX
  end
end
