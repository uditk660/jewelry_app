module Users
  class SessionsController < Devise::SessionsController
    # Ensure mapping is set when this controller is invoked directly via explicit routes
    before_action :set_devise_mapping

    private

    def set_devise_mapping
      request.env['devise.mapping'] ||= Devise.mappings[:user]
    end
  end
end
