# encoding: UTF-8

require 'devise/registrations_controller'

class ::RegistrationsController < Devise::RegistrationsController 

  # Ver SessionsController
  skip_before_filter :require_no_authentication

  def new
    if current_usuario && current_usuario.autenticado_por_ip
        sign_out(current_usuario)
    end
    build_resource({})
    respond_with self.resource
  end

  def create
    d = Mail::Address.new(params[:usuario][:email]).domain
    if Organizacion.where(dominiocorreo: d).count != 1 then
      set_flash_message :error, :correo_desconocido
      clean_up_passwords resource
      respond_with self.resource, location: '/'
    else
      #org = Organizacion.where(dominiocorreo: d).take
      params[:usuario][:nusuario] = params[:usuario][:email].gsub(/[@.]/,"_")
      params[:usuario][:fechacreacion] = Date.today
      super
    end
    #byebug
  end

  private

  def sign_up_params
    allow = [:email, :nusuario, :password, :password_confirmation, 
             :fechacreacion]
    params.require(resource_name).permit(allow)
  end

end
