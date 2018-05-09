# encoding: UTF-8
module Admin
	class OrganizacionesController < Sip::Admin::BasicasController
		before_action :set_organizacion, 
			only: [:show, :edit, :update, :destroy]
		load_and_authorize_resource  class: Organizacion

		def clase 
			"Organizacion"
		end

		def set_organizacion
			@basica = Organizacion.find(params[:id])
		end

		def atributos_index
      ["id", 
       "nombre", 
       "observaciones", 
       "usuarioip_id", 
       "autoregistro", 
       "fechacreacion_localizada", 
       "fechadeshabilitacion_localizada"  ]
		end

    def atributos_show
      ["id", 
       "nombre", 
       "observaciones", 
       "usuarioip_id", 
       "fecharenovacion",
       "diasvigencia", 
       "autoregistro", 
       "dominiocorreo", 
       "pexcluyecorreo", 
       "iporganizacion", 
       "url_logoinst",
       "opciones_url_nombre_cif",
       "opciones_url_puerto_cif",
       "opciones_url_nombre_nocif",
       "opciones_url_puerto_nocif",
       "fechacreacion_localizada", 
       "fechadeshabilitacion_localizada"  ]
		end


		def atributos_form
      atributos_show - ['id']
		end


    def new
      @registro = clase.constantize.new
      @registro.nombre = 'O'
      @registro.created_at = @registro.updated_at =  
        @registro.fechacreacion = Date.today
      
      @registro.save!(validate: false)
      redirect_to main_app.edit_admin_organizacion_path(@registro)
    end


		def organizacion_params
      at = atributos_form - ["id"] - ['iporganizacion']
      at += [ :iporganizacion_attributes => [ :id, :ipcadena, :_destroy] ]
			params.require(:organizacion).permit( *(at))
		end

	end
end
