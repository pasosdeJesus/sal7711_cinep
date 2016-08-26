# encoding: UTF-8

class ApplicationController < Sip::ApplicationController

  #protect_from_forgery with: :exception
  # intentar skip_before_action :verify_authenticity_token

  # Sobrecargamos para permitir autenticacion basada en IP
  def current_ability
    @current_ability ||= ::Ability.new(current_usuario)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "/sign_out",
      alert: Ability::ultimo_error_aut + " " + exception.message 
  end
  def after_sign_in_path_for(resource)
      sal7711_gen.buscar_path
  end
end

