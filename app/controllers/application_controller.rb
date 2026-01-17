class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  # Allow Devise controllers and the home dashboard to be viewed without authentication
  skip_before_action :authenticate_user!, if: -> { devise_controller? || (controller_name == 'home' && action_name == 'dashboard') }
end
