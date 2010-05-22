class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :activities
  has_one :avatar, :dependent => :destroy
  has_many :userroles, :class_name => "UserRole"
  has_many :roles, :through => :userroles

  attr_accessor :remember_me
  attr_accessor :current_password
  attr_accessor :admin
  attr_accessor :updating_user

  USERNAME_MIN_LENGTH = 4
  USERNAME_MAX_LENGTH = 20
  PASSWORD_MIN_LENGTH = 4
  PASSWORD_MAX_LENGTH = 20
  EMAIL_MAX_LENGTH = 50
  BLOG_MAX_LENGTH = 100
  USERNAME_SIZE = 30
  PASSWORD_SIZE = 30
  EMAIL_SIZE = 30
  BLOG_URL_SIZE = 30
  USERNAME_RANGE = USERNAME_MIN_LENGTH..USERNAME_MAX_LENGTH
  PASSWORD_RANGE = PASSWORD_MIN_LENGTH..PASSWORD_MAX_LENGTH
  VALID_GENDERS = ["Jis", "Ji"]
  START_YEAR = 1950
  VALID_DATES = DateTime.new(START_YEAR)..DateTime.now

  validates_confirmation_of :password, :unless => :updating_user
  validates_length_of     :username, :within => USERNAME_RANGE
  validates_length_of     :password, :within => PASSWORD_RANGE, :unless => :updating_user
  validates_length_of     :email,   :maximum => EMAIL_MAX_LENGTH 
  validates_length_of     :blog_url, :maximum => BLOG_MAX_LENGTH, :allow_nil => true 
  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                      :message => I18n.t(:must_be_valid) 
  validates_format_of :username,
                      :with => /^[A-Z0-9_-]*$/i,
                      :message => I18n.t(:username_error)

  validates_inclusion_of :gender, 
                         :in => VALID_GENDERS,
                         :allow_nil => true,
                         :message => "Apsispręsk, vyras ar moteris?"
  validates_inclusion_of :birthdate, 
                         :in => VALID_DATES,
                         :allow_nil => true,
                         :message => "neteisinga data"

  def name_surname
    if !self.name.nil? && !self.surname.nil?
      self.name + " " + self.surname
    elsif self.name.nil?
      self.surname
    elsif self.surname.nil?
      self.name
    else
      " "
    end
  end

  def clear_password!
    self.password = nil
    self.password_confirmation = nil
    self.current_password = nil
  end


end
