class User < ActiveRecord::Base
  # Attach Devise modules only when Devise is loaded to avoid load-order issues.
  if defined?(Devise)
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable
  end
end
