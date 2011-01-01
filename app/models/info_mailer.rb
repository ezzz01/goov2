class InfoMailer < ActionMailer::Base

  default_url_options[:host] = "go-out.lt"

  def inform_about_new_registration(username)
    charset    'utf8'
    subject    'Naujas vartotojas'
    recipients 'admin@go-out.lt'
    from       'admin@go-out.lt'
    sent_on    Time.now
    body       :username => username 
  end

  def greet_new_user(username, address)
    charset    'utf8'
    subject    'Registracija go-out.lt'
    recipients address 
    from       'admin@go-out.lt'
    sent_on    Time.now
    body       :username => username 
  end

  def password_reset_instructions(user)
    charset    'utf8'
    subject    'go-out.lt slaptažodžio atstatymas'
    recipients user.email 
    from       'admin@go-out.lt'
    sent_on    Time.now
    body      :edit_password_reset_url => edit_password_reset_url(user.perishable_token)    
  end
  
end
