class BaseMailer < ActionMailer::Base
  self.mailer_name = "base_mailer"

  default :to => 'system@test.lindsaar.net',
          :from => 'jose@test.plataformatec.com',
          :reply_to => 'mikel@test.lindsaar.net'

  def welcome(hash = {})
    headers['X-SPAM'] = "Not SPAM"
    mail({:subject => "The first email on new API!"}.merge!(hash))
  end

  def welcome_with_headers(hash = {})
    headers hash
    mail
  end

  def welcome_from_another_path(path)
    mail(:template_name => "welcome", :template_path => path)
  end

  def html_only(hash = {})
    mail(hash)
  end

  def plain_text_only(hash = {})
    mail(hash)
  end

  def inline_attachment
    attachments.inline['logo.png'] = "\312\213\254\232"
    mail
  end

  def attachment_with_content(hash = {})
    attachments['invoice.pdf'] = 'This is test File content'
    mail(hash)
  end

  def attachment_with_hash
    attachments['invoice.jpg'] = { :data => "\312\213\254\232)b",
                                   :mime_type => "image/x-jpg",
                                   :transfer_encoding => "base64" }
    mail
  end

  def attachment_with_hash_default_encoding
    attachments['invoice.jpg'] = { :data => "\312\213\254\232)b",
                                   :mime_type => "image/x-jpg" }
    mail
  end

  def implicit_multipart(hash = {})
    attachments['invoice.pdf'] = 'This is test File content' if hash.delete(:attachments)
    mail(hash)
  end

  def implicit_with_locale(hash = {})
    mail(hash)
  end

  def explicit_multipart(hash = {})
    attachments['invoice.pdf'] = 'This is test File content' if hash.delete(:attachments)
    mail(hash) do |format|
      format.text { render :text => "TEXT Explicit Multipart" }
      format.html { render :text => "HTML Explicit Multipart" }
    end
  end

  def explicit_multipart_templates(hash = {})
    mail(hash) do |format|
      format.html
      format.text
    end
  end

  def explicit_multipart_with_any(hash = {})
    mail(hash) do |format|
      format.any(:text, :html){ render :text => "Format with any!" }
    end
  end

  def explicit_multipart_with_options(include_html = false)
    mail do |format|
      format.text(:content_transfer_encoding => "base64"){ render "welcome" }
      format.html{ render "welcome" } if include_html
    end
  end

  def explicit_multipart_with_one_template(hash = {})
    mail(hash) do |format|
      format.html
      format.text
    end
  end

  def implicit_different_template(template_name='')
    mail(:template_name => template_name)
  end

  def explicit_different_template(template_name='')
    mail do |format|
      format.text { render :template => "#{mailer_name}/#{template_name}" }
      format.html { render :template => "#{mailer_name}/#{template_name}" }
    end
  end

  def different_layout(layout_name='')
    mail do |format|
      format.text { render :layout => layout_name }
      format.html { render :layout => layout_name }
    end
  end
end
