# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_libre_session',
  :secret => '45fffa2a879ff24b5fe44224922ea043dd4da48b7736224d77b384167c6fa0dc3dfc1f36ec76e8012d32cf787e889782fe1892012cb1a75a798105672fb02939'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
