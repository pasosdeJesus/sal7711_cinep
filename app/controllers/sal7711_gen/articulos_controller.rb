# encoding: UTF-8

require 'sal7711_gen/concerns/controllers/articulos_controller'

module Sal7711Gen
  class ArticulosController < ApplicationController
 
    include Sal7711Gen::Concerns::Controllers::ArticulosController    

    # GET /articulos/1/edit
    def edit
      authorize! :edit, Sal7711Gen::Articulo
      prepara_imagenes(@articulo.id)
      if @articulo.lote_id && 
        @articulo.adjunto_descripcion.starts_with?('Imagen')
        lote = ::Lote.find(@articulo.lote_id)
        @icfecha = false
        if lote.candfecha
          @articulo.fecha = lote.candfecha 
          @icfecha = true
        end
        @icdepartamento = false
        if lote.canddepartamento_id
          @articulo.departamento_id = lote.canddepartamento_id 
          @icdepartamento = true
        end
        @icmunicipio = false
        if lote.candmunicipio_id
          @articulo.municipio_id = lote.candmunicipio_id 
          @icmunicipio = true
        end
        @icfuenteprensa = false
        if lote.candfuenteprensa_id
          @articulo.fuenteprensa_id = lote.candfuenteprensa_id
          @icfuenteprensa = true
        end

      end
    end


    def gen_descripcion_categoria_bd articulo
      return articulo.articulo_categoriaprensa.order(:orden).to_a.map {|i| 
        i.categoriaprensa_id 
      }.uniq.inject("") { 
        |memo, i| 
        c = Sal7711Gen::Categoriaprensa.find(i).codigo
        memo == "" ? c : memo + ", " + c 
      }
    end

    # Completa @articulo
    def ordena_articulo
      #byebug
      orden = 0
      articulo_params[:categoriaprensa_ids].each do |c|
        puts c
        if c != ''
          @articulo.articulo_categoriaprensa.each do |a|
            if a.categoriaprensa_id == c.to_i
              a.orden = orden
              a.save if a.articulo_id
            end
          end
        end
        orden += 1
      end
      @articulo.adjunto_descripcion = 
        Sal7711Gen::ArticulosController.gen_descripcion_bd(@articulo)
      @articulo.save
    end

    def actualiza_lote(par)
      if @articulo.lote_id
        lote = ::Lote.find(@articulo.lote_id)
        lote.candfecha = par[:icfecha] ? @articulo.fecha : nil
        lote.canddepartamento_id = par[:icdepartamento] ? 
          @articulo.departamento_id : nil
        lote.candmunicipio_id = par[:icmunicipio] ? @articulo.municipio_id :
          nil
        lote.candfuenteprensa_id = par[:icfuenteprensa] ? 
          @articulo.fuenteprensa_id : nil
        lote.save
      end
    end

    # PATCH/PUT /articulos/1
    # PATCH/PUT /articulos/1.json
    def update
      authorize! :edit, Sal7711Gen::Articulo
      respond_to do |format|
        if @articulo.update(articulo_params)
          ordena_articulo
          #byebug
          actualiza_lote(request.params[:articulo])
          format.html { 
            if @articulo.lote_id && params[:progresar] == 'Actualizar y progresar'
              # Primero los no editados ordenados por nombre de archivo (posteriores primero, anteriores despues)
              # A continuación los editados pero sin categorias completas también ordenados por nombre de archivo
             sig = Sal7711Gen::Articulo.connection.select_one(
               "SELECT articulo_id FROM vcatporarticulo 
                JOIN sal7711_gen_articulo ON 
                vcatporarticulo.articulo_id=sal7711_gen_articulo.id
                WHERE vcatporarticulo.lote_id='#{@articulo.lote_id.to_i}' 
                AND orden > '#{@articulo.orden}' 
                AND substring(adjunto_descripcion from 1 for 6) = 'Imagen'
                ORDER BY orden LIMIT 1;")  
             if !sig
               sig = Sal7711Gen::Articulo.connection.select_one(
                 "SELECT articulo_id FROM vcatporarticulo 
                  JOIN sal7711_gen_articulo ON 
                  vcatporarticulo.articulo_id=sal7711_gen_articulo.id
                  WHERE vcatporarticulo.lote_id='#{@articulo.lote_id.to_i}' 
                  AND orden < '#{@articulo.orden}' 
                  AND substring(adjunto_descripcion from 1 for 6) = 'Imagen'
                  ORDER BY orden LIMIT 1;")  
             end
             if !sig
               sig = Sal7711Gen::Articulo.connection.select_one(
                 "SELECT articulo_id FROM vcatporarticulo 
                  JOIN sal7711_gen_articulo ON 
                  vcatporarticulo.articulo_id=sal7711_gen_articulo.id
                  WHERE vcatporarticulo.lote_id='#{@articulo.lote_id.to_i}' 
                  AND articulo_id>'#{@articulo.id.to_i}' 
                  AND ncat = 0
                  ORDER BY orden LIMIT 1;")  
             end
             if !sig
               sig = Sal7711Gen::Articulo.connection.select_one(
                 "SELECT articulo_id FROM vcatporarticulo 
                  JOIN sal7711_gen_articulo ON 
                  vcatporarticulo.articulo_id=sal7711_gen_articulo.id
                  WHERE vcatporarticulo.lote_id='#{@articulo.lote_id.to_i}' 
                  AND articulo_id<'#{@articulo.id.to_i}' 
                  AND ncat = 0
                  ORDER BY orden LIMIT 1;")  
             end

             if sig
               redirect_to edit_articulo_path(sig["articulo_id"]), 
                 notice: 'Artículo actualizado y progresando en lote.' 
             else
               redirect_to @articulo,
                 notice: 'Artículo actualizado. Lote procesado.' 
             end
            else
              redirect_to @articulo, notice: 'Artículo actualizado.' 
            end
          }
          format.json { render :show, status: :ok, location: @articulo }
        else
          format.html { render :edit }
          format.json { 
            render json: @articulo.errors, status: :unprocessable_entity 
          }
        end
      end
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def articulo_params
      params.require(:articulo).permit(
        :departamento_id, 
        :municipio_id, 
        :fuenteprensa_id, 
        :fecha_localizada, 
        :pagina,
        :texto,
        :adjunto_descripcion,
        :adjunto,
        :archivo,
        {:categoriaprensa_ids => []}
      )
    end

  end
end
