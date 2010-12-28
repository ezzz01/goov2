class InfoMailer < ActionMailer::Base
  

  def inform_about_new_registration(username, sent_at = Time.now)
    charset    'utf8'
    subject    'Naujas vartotojas'
    recipients 'admin@go-out.lt'
    from       'admin@go-out.lt'
    sent_on    sent_at
    body       :username => username 
  end

  def greet_new_user(username, address, sent_at = Time.now)
    charset    'utf8'
    subject    'Registracija go-out.lt'
    recipients address 
    from       'admin@go-out.lt'
    sent_on    sent_at
    body       :username => username 
  end

end
