class User < ActiveRecord::Base
  acts_as_authentic
  
  after_create :register_user_to_fb

  has_many :activities
  belongs_to :current_country, :class_name => "Country"
  has_one :avatar, :dependent => :destroy
  has_many :userroles, :class_name => "UserRole"
  has_many :roles, :through => :userroles
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  has_many :votes, :dependent => :nullify

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
    if !self.name.blank? && !self.surname.blank?
      self.name + " " + self.surname
    elsif self.name.blank?
      self.surname
    elsif self.surname.blank?
      self.name
    else
      ""
    end
  end

  def clear_password!
    self.password = nil
    self.password_confirmation = nil
    self.current_password = nil
  end

#The Facebook registers user method is going to send the users email hash and our account id to Facebook
#We need this so Facebook can find friends on our local application even if they have not connect through connect
#We then use the email hash in the database to later identify a user from Facebook with a local user
  def register_user_to_fb
    users = {:email => email, :account_id => id}
    Facebooker::User.register([users])
    self.email_hash = Facebooker::User.hash_email(email)
    save(false)
  end
 
#Take the data returned from facebook and create a new user from it.
#We don't get the email from Facebook and because a facebooker can only login through Connect we just generate a unique login name for them.
#If you were using username to display to people you might want to get them to select one after registering through Facebook Connect
  def self.create_from_fb_connect(fb_user)
    new_facebooker = User.new(:name => fb_user.first_name, :surname => fb_user.last_name, :username => fb_user.first_name+" "+fb_user.last_name, :password => "", :email => "")
    new_facebooker.fb_user_id = fb_user.uid.to_i

    #We need to save without validations
    new_facebooker.save(false)

    #copy avatar from FB (rewrite current avatar in go-out.lt):
    #TODO - let choose if rewrite current
    avatar = Avatar.new(:user_id => new_facebooker.id, :thumbnail => fb_user.pic_square, :fb_avatar => true)
    avatar.save(false)
  end
 
#We are going to connect this user object with a facebook id. But only ever one account.
  def link_fb_connect(fb_user_id)
    unless fb_user_id.nil?
      #check for existing account
      existing_fb_user = User.find_by_fb_user_id(fb_user_id)
   
      #unlink the existing account
      unless existing_fb_user.nil?
        existing_fb_user.fb_user_id = nil
        existing_fb_user.save(false)
      end
   
      #link the new one
      self.fb_user_id = fb_user_id
      save(false)
    end
  end
 

  def self.find_by_fb_user(fb_user)
    User.find_by_fb_user_id(fb_user.uid) || User.find_by_email_hash(fb_user.email_hashes)
  end

  def facebook_user?
    return !fb_user_id.nil? && fb_user_id > 0
  end



  def voted_for?(voteable)
    0 < Vote.count(:all, :conditions => [ "user_id = ? AND vote = ? AND voteable_id = ?", self.id, 1, voteable.id ])
  end

  def voted_against?(voteable)
    0 < Vote.count(:all, :conditions => [ "user_id = ? AND vote = ? AND voteable_id = ? ", self.id, "-1", voteable.id ])
  end

  def voted_on?(voteable)
    0 < Vote.count(:all, :conditions => [ "user_id = ? AND voteable_id = ? ", self.id, voteable.id ])
  end


end
