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
      ["id", "nombre", "observaciones", "autoregistro", 
       "dominiocorreo", "pexcluyecorreo", "fecharenovacion",
       "diasvigencia", "ip_organizacion", "usuarioip_id", 
       "url_logoinst",
       "opciones_url_nombre_cif",
       "opciones_url_puerto_cif",
       "opciones_url_nombre_nocif",
       "opciones_url_puerto_nocif",
       "fechacreacion", "fechadeshabilitacion"  ]
		end

		def organizacion_params
			params.require(:organizacion).permit( *(atributos_index - ["id"]))
		end

	end
end
