require 'gon'

class ApplicationController < ActionController::Base
  before_filter :authenticate_user!
  before_filter :reject_blocked!
  before_filter :check_password_expiration
  around_filter :set_current_user_for_thread
  before_filter :add_abilities
  before_filter :ldap_security_check
  before_filter :dev_tools if Rails.env == 'development'
  before_filter :default_headers
  before_filter :add_gon_variables
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :require_email, unless: :devise_controller?

  protect_from_forgery

  helper_method :abilities, :can?

  rescue_from Encoding::CompatibilityError do |exception|
    log_exception(exception)
    render "errors/encoding", layout: "errors", status: 500
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    log_exception(exception)
    render "errors/not_found", layout: "errors", status: 404
  end

  protected

  def log_exception(exception)
    application_trace = ActionDispatch::ExceptionWrapper.new(env, exception).application_trace
    application_trace.map!{ |t| "  #{t}\n" }
    logger.error "\n#{exception.class.name} (#{exception.message}):\n#{application_trace.join}"
  end

  def reject_blocked!
    if current_user && current_user.blocked?
      sign_out current_user
      flash[:alert] = "Your account is blocked. Retry when an admin has unblocked it."
      redirect_to new_user_session_path
    end
  end

  def after_sign_in_path_for resource
    if resource.is_a?(User) && resource.respond_to?(:blocked?) && resource.blocked?
      sign_out resource
      flash[:alert] = "Your account is blocked. Retry when an admin has unblocked it."
      new_user_session_path
    else
      super
    end
  end

  def set_current_user_for_thread
    Thread.current[:current_user] = current_user
    begin
      yield
    ensure
      Thread.current[:current_user] = nil
    end
  end

  def abilities
    @abilities ||= Six.new
  end

  def can?(object, action, subject)
    abilities.allowed?(object, action, subject)
  end

  def add_abilities
    abilities << Ability
  end

  def authorize_project!(action)
    return access_denied! unless can?(current_user, action, project)
  end

  def access_denied!
    render "errors/access_denied", layout: "errors", status: 404
  end

  def not_found!
    render "errors/not_found", layout: "errors", status: 404
  end

  def git_not_found!
    render "errors/git_not_found", layout: "errors", status: 404
  end

  def method_missing(method_sym, *arguments, &block)
    if method_sym.to_s =~ /^authorize_(.*)!$/
      authorize_project!($1.to_sym)
    else
      super
    end
  end

  def render_403
    head :forbidden
  end

  def render_404
    render file: Rails.root.join("public", "404"), layout: false, status: "404"
  end

  def require_non_empty_project
    redirect_to @project if @project.empty_repo?
  end

  def no_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def dev_tools
  end

  def default_headers
    headers['X-Frame-Options'] = 'DENY'
    headers['X-XSS-Protection'] = '1; mode=block'
    headers['X-UA-Compatible'] = 'IE=edge'
    headers['X-Content-Type-Options'] = 'nosniff'
    headers['Strict-Transport-Security'] = 'max-age=31536000' if Gitlab.config.gitlab.https
  end

  def add_gon_variables
    #gon.default_issues_tracker = Project.issues_tracker.default_value
    gon.api_version = API::API.version
    gon.api_token = current_user.private_token if current_user
    gon.gravatar_url = request.ssl? || Gitlab.config.gitlab.https ? Gitlab.config.gravatar.ssl_url : Gitlab.config.gravatar.plain_url
    gon.relative_url_root = Gitlab.config.gitlab.relative_url_root
    gon.gravatar_enabled = Gitlab.config.gravatar.enabled
  end

  def check_password_expiration
    if current_user && current_user.password_expires_at && current_user.password_expires_at < Time.now  && !current_user.ldap_user?
      redirect_to new_profile_password_path and return
    end
  end

  def ldap_security_check
    if current_user && current_user.requires_ldap_check?
      gitlab_ldap_access do |access|
        if access.allowed?(current_user)
          current_user.last_credential_check_at = Time.now
          current_user.save
        else
          sign_out current_user
          flash[:alert] = "Access denied for your LDAP account."
          redirect_to new_user_session_path
        end
      end
    end
  end

  def event_filter
    if cookies['event_filter'].present?
      filters = cookies['event_filter'].split(',')
      #cookies['event_filter'] = EventFilter.default_filter.join(",")
    end
    @event_filter ||= EventFilter.new(filters)
  end

  def gitlab_ldap_access(&block)
    Gitlab::LDAP::Access.open { |access| block.call(access) }
  end

  # JSON for infinite scroll via Pager object
  def pager_json(partial, count)
    html = render_to_string(
      partial,
      layout: false,
      formats: [:html]
    )

    render json: {
      html: html,
      count: count
    }
  end

  def view_to_html_string(partial)
    render_to_string(
      partial,
      layout: false,
      formats: [:html]
    )
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password, :login, :remember_me) }
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :name, :password, :password_confirmation) }
  end

  def hexdigest(string)
    Digest::SHA1.hexdigest string
  end

  def require_email
    if current_user && current_user.temp_oauth_email?
      redirect_to profile_path, notice: 'Please complete your profile with email address' and return
    end
  end

end
