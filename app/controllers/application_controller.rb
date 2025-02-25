class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend
  include Passwordless::ControllerHelpers
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  before_action :configure_json_pretty_printing
  around_action :switch_locale

  helper_method :current_user

  def audit_user
    if current_user
      current_user
    else
      User.system_user
    end
  end

  def switch_locale(&action)
    locale = params[:lang] || I18n.default_locale
    @pagy_locale = locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options(options = {})
    { lang: I18n.locale }.merge(options)
  end

  private

  def current_user
    @current_user = authenticate_by_session(User) unless @current_user
    @current_user = authenticate_by_api_key unless @current_user
    @current_user
  end

  def authenticate_by_api_key
    begin
      user = User.find(params[:user_id])
      api_key = params[:api_key]
      if user.has_role?(:api) && user.authenticate_api_key(api_key)
        user
      else
        nil
      end
    rescue Exception => e
      nil
    end
  end

  def configure_json_pretty_printing
    @prettify_json = Rails.env.development?
  end

  def user_not_authorized(exception)
    # policy_name = exception.policy.class.to_s.underscore
    respond_to do |format|
      format.html do
        redirect_to(error_403_path)
      end
      format.json do
        redirect_to(error_403_path(format: :json))
      end
    end
  end
end