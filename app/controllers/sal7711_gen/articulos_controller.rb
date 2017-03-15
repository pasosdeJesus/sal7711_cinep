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
        @iccategoriaprensa = false
        if lote.candcategoria1_id
          @articulo.categoriaprensa_ids = [lote.candcategoria1_id,
            lote.candcategoria2_id, lote.candcategoria3_id]
          @iccategoriaprensa = true
        end

      end
    end


    def self.gen_descripcion_categoria_bd articulo
      ac = articulo.articulo_categoriaprensa.order(:orden).to_a
      lc = ac.map {|i| 
        i.categoriaprensa_id 
      }.uniq.inject("") { 
        |memo, i| 
        c = Sal7711Gen::Categoriaprensa.find(i).codigo
        memo == "" ? c : memo + ", " + c 
      }
      return lc
    end

    # Completa @articulo
    def ordena_articulo
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
        byebug
        lote = ::Lote.find(@articulo.lote_id)
        lote.candfecha = par[:icfecha] ? @articulo.fecha : nil
        lote.canddepartamento_id = par[:icdepartamento] ? 
          @articulo.departamento_id : nil
        lote.candmunicipio_id = par[:icmunicipio] ? @articulo.municipio_id :
          nil
        lote.candfuenteprensa_id = par[:icfuenteprensa] ? 
          @articulo.fuenteprensa_id : nil
        if (par[:iccategoriaprensa]) 
          a = @articulo.articulo_categoriaprensa.where(orden: 1).take
          lote.candcategoria1_id = a ? a.categoriaprensa_id : nil
          a = @articulo.articulo_categoriaprensa.where(orden: 2).take
          lote.candcategoria2_id = a ? a.categoriaprensa_id : nil
          a = @articulo.articulo_categoriaprensa.where(orden: 3).take
          lote.candcategoria3_id = a ? a.categoriaprensa_id : nil
        end
        lote.save
      end
    end

    # PATCH/PUT /articulos/1
    # PATCH/PUT /articulos/1.json
    def update
      authorize! :edit, Sal7711Gen::Articulo
      respond_to do |format|
        if @articulo.update(articulo_params)
          Sal7711Gen::Bitacora.a( request.remote_ip, current_usuario, 
                                 'edita', params, @articulo.id, 
                                 @articulo.lote_id)
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
               redirect_to edit_articulo_path(sig["id"])#, 
                 #notice: 'Artículo actualizado y progresando en lote.' 
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

    # Programa eliminaciòn de archivo ruta con comentario com
    def porelim_sa(f, ruta, com)
      f.puts "rm -f #{File.join(Sip.ruta_anexos, ruta)} # #{com}"
      @numelimsa += 1
      if (@numelimsa % 1000) == 1
        f.puts "echo \"#{@numelimsa}\""
      end
      #@cprob += com
    end

    # Genera SQL para eliminar artículo con id dada
    def gen_sql_elim(id)
      return "DELETE FROM sal7711_gen_articulo_categoriaprensa " +
        " WHERE articulo_id='#{id.to_i}'; " +
        "DELETE FROM sal7711_gen_articulo WHERE id='#{id.to_i}';"
    end

    # Programa eliminación de registro id en BD con comentario com
    def porelim_bd(f, id, com)
      f.puts gen_sql_elim(id) + "-- #{com}"
      #@cprob += com
      @numelimbd += 1
      if (@numelimbd % 1000) == 1
        f.puts "-- #{@numelimbd}"
      end
    end

    # Genera listado de rutas a archivos en sistema de archivos,
    # esperando que estén en directorios de la forma año/mes/dia
    # Genera en @arcsa
    def gen_rutas_sa(ruta)
      Dir.entries(ruta).sort.each do |arc|
        if arc == '.' || arc == '..'
          next
        end
        nr = File.join(ruta, arc)
        if File.stat(nr).ftype == 'directory'
                gen_rutas_sa(nr)
        else
          f = nr.split(File::SEPARATOR)[-4..-2]
          if f[0].to_i < 1970 || 
            f[1].to_i <=0 || f[1].to_i > 12 || 
            f[2].to_i <=0 || f[2].to_i > 31
            porelim_sa(nr, 
                    "Archivo #{nr} no incluye fecha correcta, " +
                    "programando eliminacion")
            next
          end
          @arcsa[@numarcsa] = File.join(f[0], f[1], f[2], arc)
          @numarcsa += 1
          if @numarcsa % 1000 == 1 
            logger.debug "OJO gen_rutas_sa @numarcsa = #{@numarcsa}"
          end
        end
      end
    end

    # Genera listado de rutas a archivos referenciados en BD
    # Genera en @arcbd
    def arregla_desc
      arts = Sal7711Gen::Articulo.where('id>664700')
      logger.debug "#{arts.count} archivos referenciados en base de datos"
      i2 = 0
      corregidos = 0
      arts.find_each(batch_size: 100000) do |art|
        i2 += 1
        if ((i2 % 1000) == 1)
          logger.debug "OJO arregla_desc=#{i2}"
        end
        desc = Sal7711Gen::ArticulosController.gen_descripcion_bd(art)
        if art.adjunto_descripcion != desc
          puts "** Corrigiendo #{art.id}"
          art.adjunto_descripcion = desc
          art.save
          corregidos += 1
          puts "** Van #{corregidos} corregidos"
        end

      end
      puts "Terminado"
      byebug
    end


    # Genera listado de rutas a archivos referenciados en BD
    # Genera en @arcbd
    def gen_rutas_bd
      arts = Sal7711Gen::Articulo.all
      logger.debug "#{arts.count} archivos referenciados en base de datos"
      arcbd = Array.new(arts.count)
      i2 = 0
      arts.find_each(batch_size: 100000) do |art|
        rr = File.join(art.created_at.strftime("%Y/%m/%d"), 
                       art.id.to_s + '_' + art.adjunto_file_name)
        arcbd[i2] = [art.id, rr]
        i2 += 1
        if ((i2 % 1000) == 1)
          logger.debug "OJO gen_rutas_bd i2=#{i2}"
        end
      end

      arcbd.sort! { |x, y| x[1] <=> y[1] }
      return arcbd
    end

    def verifica_arch_base(ruta)
      Dir.foreach(ruta) do |arc|
        if arc == '.' || arc == '..'
          next
        end
        nr = File.join(ruta, arc)
        if File.stat(nr).ftype == 'directory'
                verifica_arch_base(nr)
        else
          f = nr.split(File::SEPARATOR)[-4..-2]
          if f[0].to_i < 1970 || 
            f[1].to_i <=0 || f[1].to_i > 12 || 
            f[2].to_i <=0 || f[2].to_i > 31
            porelim_sa(nr, 
                    "Archivo #{nr} no incluye fecha correcta, " +
                    "programando eliminacion")
            next
          end
          p = arc.split("_")
          if p[0].to_i <= 0
            porelim_sa(nr, "Archivo #{nr} no incluye id.,"+
                    "programando eliminacion")
            next
          end
          art = Sal7711Gen::Articulo.where(id: p[0].to_i).take
          if (art.nil?) 
            
            porelim_sa(nr, "Archivo #{nr} referencia artículo con " +
                    "id #{p[0].to_i} pero no existe, " +
                    "programando eliminación")
            next
          end
          if art.created_at.year != f[0].to_i ||
            art.created_at.month != f[1].to_i ||
            art.created_at.day != f[2].to_i 
            porelim_sa(nr, "Archivo #{nr} está en una ruta con " +
                    "fecha diferente a la del artículo con id " +
                    "#{p[0].to_i} que es " +
                    "#{art.created_at.strftime('%Y-%m-%d')}, " +
                    "programando eliminación" )
            next
          end
          p.delete_at(0)
          oarc = p.join("_")
          if art.adjunto_file_name != oarc
            porelim_sa(nr, "Archivo #{nr} no es referenciado por " +
                    "el artículo con id #{p[0].to_i} " +
                    "(referenciado #{art.adjunto_file_name}), " +
                    "programando eliminación")
            next
          end

        end
      end
    end

    # Calcula diferencia entre archivos en sistema de archivos
    # y los referenciados en base de datos para generar:
    # a) Archivo de ordenes para borrar excedente de sist. arch
    # b) Archivo SQL para borrar excedente de bd
    # c) Archivo de ordenes para revisar integridad de archivos
    #    existentes y referenciados y que agrega eliminacion
    #    de los que no sean imagenes integras
    def verifica_archivos
      authorize! :edit, Sal7711Gen::Articulo
      ActiveRecord::Base.uncached do
        @cprob = '' # Colchon de errores
        @numelimsa = 0 # Número de problemas en SA
        @numelimbd = 0 # Número de problemas en BD
        @numexistente = 0 # Número de comunes en SA y BD
        @saelim='/tmp/rbverifica-elimina-sa.sh'
        @bdelim='/tmp/rbverifica-elimina-bd.sql'
        @arcord='/tmp/rbverifica.sh'
        arregla_desc
        @arcbd = gen_rutas_bd
        puts "#{@arcbd.length} archivos referenciados en base de datos"
        @numarcsa = 0
        @arcsa = Array.new(@arcbd.lengt)
        gen_rutas_sa(File.join(Sip.ruta_anexos))
        puts "#{@numarcsa} archivos en sistema de archivos"
        @arcsa.sort!
       i1 = 0
        i2 = 0
        open(@saelim, 'w') { |fsa|
          fsa.puts "#!/bin/sh"
          fsa.puts "# Elimina archivos que no estén bien referenciados en base de datos de Archivo de prensa"
          open(@bdelim, 'w') { |fbd|
            fbd.puts "-- Elimina registros de base de datos que referencia archivos que no existen en el sistema de archivos"
            open(@arcord, 'w') { |fvi|
              fvi.puts "#!/bin/sh"
              fvi.puts "# Verifica integridad de imagenes en sistemas de archivos y referenciadas en base de datos, programa eliminacion de errados de base de datos añadiendo a #{@bdelim}"
              while i1 < @arcsa.length || i2 < @arcbd.length
                if i2 >= @arcbd.length || 
                  (i1 < @arcsa.length && @arcsa[i1] < @arcbd[i2][1])
                  porelim_sa(fsa, @arcsa[i1], "No referenciado en BD")
                  i1 += 1
                elsif i1 >= @arcsa.length ||
                  (i2 < @arcbd.length && @arcsa[i1] > @arcbd[i2][1])
                  porelim_bd(fbd, @arcbd[i2][0], "Archivo referenciado (#{@arcbd[i2][1]}) no esta en SA")
                  i2 += 1
                else # i1<@arcsa.length && i2<@arcbd.length && @arcsa[i1]==@arcbd[i2][1] 
                  fvi.puts "file #{File.join(Sip.ruta_anexos, @arcsa[i1])} | grep -e \"TIFF image\" -e \"PC bitmap data\" >> /tmp/salida 2>&1"
                  fvi.puts "if (test \"$?\" != \"0\") then {"
                  fvi.puts "  echo \"Problema en artículo #{File.join(Sip.ruta_anexos, @arcsa[i1])} borrar registro #{@arcbd[i2][0]}\" | tee -a /tmp/salida"
                  fvi.puts "  echo \"#{gen_sql_elim(@arcbd[i2][0])} -- Existe archivo #{File.join(Sip.ruta_anexos, @arcsa[i1])} pero no es imagen integra\"verificaarchivos  >> #{@bdelim}"
                  fvi.puts "} fi;"
                  i1 += 1
                  i2 += 1
                  @numexistente += 1
                  if (@numexistente % 1000) == 0
                    fvi.puts "echo \"#{@numexistente}\""
                  end
                end
                if ((i1 + i2 % 1000) == 0 || (i1 + i2 % 1000) == 1)
                  logger.debug "i1=#{i1}, i2=#{i2}, numexistente=#{@numexistente}"
                end
              end

            }
          }
        }
      end #uncached
    end


    # DELETE /articulos/1
    # DELETE /articulos/1.json
    def destroy
      authorize! :edit, Sal7711Gen::Articulo
      lotereg = @articulo.lote_id.nil? ? '' : 
        "?lotes_lote=#{@articulo.lote_id.to_s}"
      @articulo.destroy
      Sal7711Gen::Bitacora.a( request.remote_ip, current_usuario, 
                             'elimina', params, @articulo.id,
                             @articulo.lote_id)
      respond_to do |format|
        format.html { 
          ruta = File.join(Rails.configuration.relative_url_root, 
                           'lotes' + lotereg)
          #byebug
          redirect_to ruta.to_s, notice: 'Artículo eliminado.' 
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
