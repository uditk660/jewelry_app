# Attach Devise modules to User once Devise is loaded.
Rails.application.config.to_prepare do
  if defined?(Devise) && defined?(User)
    User.class_eval do
      devise :database_authenticatable, :registerable,
             :recoverable, :rememberable, :validatable
    end
  end
end
