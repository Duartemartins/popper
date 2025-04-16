class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: 'Admins only.'
    end
  end
end
