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
               "SELECT id FROM sal7711_gen_articulo 
                WHERE lote_id='#{@articulo.lote_id.to_i}' 
                  AND orden > '#{@articulo.orden}' 
                  AND substring(adjunto_descripcion from 1 for 6) = 'Imagen'
                ORDER BY orden LIMIT 1;")  
             if !sig
               sig = Sal7711Gen::Articulo.connection.select_one(
               "SELECT id FROM sal7711_gen_articulo 
                WHERE lote_id='#{@articulo.lote_id.to_i}' 
                  AND orden < '#{@articulo.orden}' 
                  AND substring(adjunto_descripcion from 1 for 6) = 'Imagen'
                  ORDER BY orden LIMIT 1;")  
             end
             if !sig
               sig = Sal7711Gen::Articulo.connection.select_one(
                "SELECT id FROM sal7711_gen_articulo 
                  WHERE lote_id='#{@articulo.lote_id.to_i}' 
                    AND id>'#{@articulo.id.to_i}' 
                    AND NOT EXISTS(SELECT * FROM sal7711_gen_articulo_categoriaprensa WHERE articulo_id=sal7711_gen_articulo.id)
                  ORDER BY orden LIMIT 1;")  
             end
             if !sig
               sig = Sal7711Gen::Articulo.connection.select_one(
                "SELECT id FROM sal7711_gen_articulo 
                  WHERE lote_id='#{@articulo.lote_id.to_i}' 
                  AND id<'#{@articulo.id.to_i}' 
                  AND NOT EXISTS(SELECT * FROM sal7711_gen_articulo_categoriaprensa WHERE articulo_id=sal7711_gen_articulo.id)
                  ORDER BY orden LIMIT 1;")  
             end

             if sig
               redirect_to edit_articulo_path(sig["id"]), 
                 notice: 'Artículo actualizado y progresando en lote.' 
             else
               redirect_to(main_app.lotes_path + 
                           "?lotes_lote=#{@articulo.lote_id.to_i}", 
                 notice: 'Artículo actualizado. Lote procesado.' )
             end
           else
             li = @articulo.lote_id ? 
               "?lotes_lote=#{@articulo.lote_id.to_i}" : ''
             redirect_to(main_app.lotes_path + li,
               notice: 'Artículo actualizado.' )
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


    def incregprob(itemnum)
          @regprob[itemnum] = 
            @regprob[itemnum].nil? ? 1 : 
            @regprob[itemnum] + 1 
    end

    def verifica_arch_base(ruta)
      Dir.foreach(ruta) do |a|
        if a == '.' || a == '..'
          next
        end
        if File.stat(a).ftype == 'directory'
          verifica_arch_base(ruta.join(a))
        else
          puts ruta.join(a).to_s
        end
      end
    end

    def verifica
      authorize! :edit, Sal7711Gen::Articulo

      verifica_arch_base(File.join(Sip.ruta_anexos))
      return
      @cprob = ''
      @numexistente = 0
      @regprob = []
      open('/tmp/rbverifica.sh', 'w') { |f|
           f.puts '#!/bin/sh'
      }
      ActiveRecord::Base.uncached do
        Sal7711Gen::Articulo.all.find_each do |a|
          open('/tmp/rbverifica.sh', 'a') { |f|
            f.puts "identify #{a.ruta_articulo} > /dev/null 2>&1"
            f.puts "if (test \"$?\" != \"0\") then {"
            f.puts "  echo \"Problema en artículo #{a.ruta_articulo} borrar registro #{a.id} del lote #{a.lote_id}\""
            f.puts "} fi;"
          }
          #        if (!File.exists? a.ruta_articulo) 
          #          prob = "<br>Artículo #{a.id} referencia archivo que no existe #{a.ruta_articulo}"
          #          logger.debug prob
          #          @cprob +=  prob
          #          incregprob(a.id)
          #        elsif !system("identify #{a.ruta_articulo} >/dev/null 2>&1") 
          #          prob = "<br>Artículo #{a.id} referencia imagen posiblemente dañada #{a.ruta_articulo}"
          #          logger.debug prob
          #          @cprob += prob
          #          incregprob(a.id)
          #        end
          @numexistente += 1
          if ((@numexistente % 1000) == 0)
            logger.debug "numexistente=#{@numexistente}"
          end
        end
      end #uncached
        
      @numregprob = @regprob.reject(&:nil?).count 

    end


    # DELETE /articulos/1
    # DELETE /articulos/1.json
    def destroy
      authorize! :edit, Sal7711Gen::Articulo
      lotereg = @articulo.lote_id.nil? ? '' : 
        "?lotes_lote=#{@articulo.lote_id.to_s}"
      @articulo.destroy
      respond_to do |format|
        format.html { 
          redirect_back fallback_location: File.join(
            Rails.configuration.relative_url_root, 'lotes', lotereg),
            notice: 'Artículo eliminado.' 
        }
        format.json { head :no_content }
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
