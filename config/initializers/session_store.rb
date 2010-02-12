# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_libre_session',
  :secret => '7c43a0e1be817fe9eef9b8f0dc4daa28eb0496e9424379ef300f8a10b83965a9a589672b06e60f8410472798d954f8089a52c63604ac3373174ea2ab083fb759'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
