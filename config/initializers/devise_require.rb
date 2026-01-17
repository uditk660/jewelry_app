# Ensure Devise is required early so route helpers like new_user_session_path are available
begin
  require 'devise'
rescue LoadError
  # Devise gem may not be available in some environments; let bundler/rake handle errors
end
