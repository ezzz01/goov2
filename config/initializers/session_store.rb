# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_goout_session',
  :secret      => '5ce966d0ff7f0497e12981f4d5024554e6a831df438ddf10baed15f4cce961f922559593e323a99aae65ff286a006892527f5b2dc4f45ea7322a78ec862e0751'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
