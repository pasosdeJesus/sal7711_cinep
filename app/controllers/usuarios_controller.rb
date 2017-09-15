# encoding: UTF-8

require 'bcrypt'

class UsuariosController < Sal7711Gen::UsuariosController

  def atributos_index
    [ "id",
      "nusuario",
      "nombre",
      "descripcion",
      "rol",
      "email",
      "created_at_localizada"
    ]
  end

  def atributos_form
    r = [ 
      "nusuario",
      "nombre",
      "descripcion",
      "rol",
      "idioma",
      "email",
    ]
    if can?(:manage, Sip::Grupo)
      r += ["sip_grupo"]
    end
    r += [
      "encrypted_password",
      "fecharenovacion_localizada",
      "diasvigencia",
      "fechacreacion_localizada",
      "fechadeshabilitacion_localizada",
      "failed_attempts",
      "unlock_token",
      "locked_at",
      "unconfirmed_email",
      "confirmation_token",
      "confirmed_at_localizada"
    ]
  end

  def new
    @miurl = crea_usuario_url 
    super
  end

  def create
    super
    @registro.confirmed_at = Date.today
    @registro.save
  end

  def edit
    @miurl = actualiza_usuario_url 
    super
  end

  def devise_registrations_edit
    authorize! :read, Sal7711Gen::Categoriaprensa
    render 'devise/registrations/edit'
  end

  def reconfirma
    #Usuaurio.where(1).send_confirmation_instructions

    #hoy = Date.today
    #::Organizacion.all.filter
    diasv = usuario.diasvigencia
    fechar = usuario.fecharenovacion
    pdom = usuario.email.split("@")
    if pdom.count == 2 
      dom = pdom[1]
      org = ::Organizacion.where(dominiocorreo: dom).take
      if org # plan corporativo correo
        diasv = org.diasvigencia
        fechar = org.fecharenovacion
      end
    end


    fechaf = fechar + diasv
    if hoy < fechar || hoy > fechaf
      raise CanCan::AccessDenied.new(
        "Sin vigencia", 
        :read, Sip::Ubicacion)
    end
  end

  # Lista blanca de paramétros
  def usuario_params
    params.require(:usuario).permit(
      :id, :nusuario, :password, 
      :nombre, :descripcion, :oficina_id,
      :rol, :idioma, :email, :encrypted_password, 
      :fecharenovacion_localizada, :diasvigencia,
      :fechacreacion_localizada, :fechadeshabilitacion_localizada, 
      :reset_password_token, 
      :reset_password_sent_at, :remember_created_at, :sign_in_count, 
      :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, 
      :failed_attempts, :unlock_token, :locked_at_localizada,
      :last_sign_in_ip, 
      :confirmation_token, :confirmed_at_localizada, 
      :confirmation_sent_at, 
      :unconfirmed_email,
      :etiqueta_ids => []
    )
  end
end
