# encoding: UTF-8

class LotesController < ApplicationController

  def new
    authorize! :edit, Lote
    @lote = Lote.new(candfecha: Date.today, usuario: current_usuario)
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
            @a.departamento_id = @lote.canddepartamento
            @a.municipio_id = @lote.candmunicipio
            @a.fuenteprensa_id = @lote.candfuenteprensa
            @a.adjunto_descripcion = "Imagen #{nim} del lote #{@lote.id}"
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
      :canddepartamento,
      :candmunicipio,
      :candfuenteprensa
    )
  end # lote_params

end
