# encoding: UTF-8


class LotesController < ApplicationController

  include Sip::FormatoFechaHelper

  def new
    authorize! :edit, Lote
    @lote = Lote.new(candfecha: Date.today, 
                     nombre: fecha_estandar_local(Date.today.to_s),
                     usuario: current_usuario)
  end

  def create
    authorize! :edit, Lote
    # Referencia: http://www.railscook.com/recipes/multiple-files-upload-with-nested-resource-using-paperclip-in-rails/
    #byebug
    @lote = Lote.new(lote_params)
    @lote.usuario = current_usuario
    respond_to do |format|
      if @lote.save
        if params[:imagenes]
          nim = 0
          params[:imagenes].each { |imagen|
            #byebug
            nim += 1
            @a = @lote.articulos.create(adjunto: imagen)
            @a.fecha = @lote.candfecha
            @a.departamento_id = @lote.canddepartamento_id
            @a.municipio_id = @lote.candmunicipio_id
            @a.fuenteprensa_id = @lote.candfuenteprensa_id
            nar = Pathname(@a.adjunto_file_name).sub_ext('').to_s.to_i
            if nar > 0 && nar < 1000
                @a.orden = "0" + @a.adjunto_file_name
                @a.orden = "0" + @a.orden if nar.to_s.to_i < 100
                @a.orden = "0" + @a.orden if nar.to_s.to_i < 10
            else
              @a.orden = @a.adjunto_file_name
            end
            @a.adjunto_descripcion = "Imagen #{@a.orden} del lote #{@lote.id}"
            @a.save(validate: false)
          }
        end
        format.html { redirect_to sal7711_gen.articulos_path, 
                      notice: 'Lote creado.' }
        format.json { render json: @lote, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @lote.errors, 
                      status: :unprocessable_entity }
      end
    end
  end # create


  def lote_params
    params.require(:lote).permit(
      :candfecha_localizada,
      :nombre,
      :canddepartamento_id,
      :candmunicipio_id,
      :candfuenteprensa_id
    )
  end # lote_params

end
