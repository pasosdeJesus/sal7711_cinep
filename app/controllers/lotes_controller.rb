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

  def orden_articulos
    'fecha, adjunto_descripcion'
  end

  @@porpag = 20

  # Prepara una página de resultados
  def prepara_pagina
    @articulos = Sal7711Gen::Articulo.all
    ActiveRecord::Base.connection.execute(
      'CREATE OR REPLACE VIEW vcatporarticulo AS 
        SELECT lote_id, sal7711_gen_articulo.id AS articulo_id, 
        COUNT(sal7711_gen_articulo_categoriaprensa.categoriaprensa_id) AS ncat 
        FROM sal7711_gen_articulo LEFT JOIN 
        sal7711_gen_articulo_categoriaprensa 
        ON articulo_id=sal7711_gen_articulo.id group by 1,2'
    )
    ActiveRecord::Base.connection.execute(
      'CREATE OR REPLACE VIEW vestadisticalote AS 
        SELECT DISTINCT lote_id, COALESCE(ARRAY_LENGTH(ARRAY(
        SELECT articulo_id FROM vcatporarticulo WHERE 
        vcatporarticulo.lote_id=sal7711_gen_articulo.lote_id AND ncat=0),1), 0)
        AS SIN, COALESCE(ARRAY_LENGTH(ARRAY(
        SELECT articulo_id from vcatporarticulo WHERE 
        vcatporarticulo.lote_id=sal7711_gen_articulo.lote_id and ncat>0),1), 0)
        AS con FROM sal7711_gen_articulo;'
    )
    ActiveRecord::Base.connection.execute(
      "CREATE OR REPLACE VIEW vestadolote AS 
        SELECT CASE WHEN con='0' THEN 'EN ESPERA' 
        WHEN sin=0 THEN 'PROCESADO' ELSE 'EN PROGRESO' END AS estado, 
        lote_id, DATE(created_at) AS fecha 
        FROM vestadisticalote JOIN lote ON vestadisticalote.lote_id=lote.id
        ORDER BY 1, 2;"
    )
    if params[:lotes] && params[:lotes][:lote] && 
      params[:lotes][:lote] != ''
      pl = params[:lotes][:lote].to_i
      @articulos = @articulos.where('lote_id = ?', pl)
    end
    
    @numregistros = @articulos.count
    @articulos = @articulos.order(orden_articulos).select(
      "sal7711_gen_articulo.id AS id, " +
      "sal7711_gen_articulo.adjunto_descripcion AS titulo, " +
      "sal7711_gen_articulo.texto AS texto"
    )
    @coltexto = "titulo"
    @colid = "id"
    @coldesc = "texto"
    pag = 1
    if (params[:pag])
      pag = params[:pag].to_i
    end
    @entradas = WillPaginate::Collection.create(
      pag, @@porpag, @numregistros
    ) do |paginador|
      c = @articulos.to_sql 
      if (paginador.offset == 0) 
        desp = 0
        limite = paginador.per_page + 1
      else
        desp = paginador.offset - 1
        limite = paginador.per_page + 2
      end
      c += " LIMIT #{limite} OFFSET #{desp}"
      puts "OJO c=#{c}"
      result = ActiveRecord::Base.connection.execute(c)
      puts result
      arr = []
      num = 0;
      ultid = ''
      result.try(:each) do |fila|
        if arr.last
          arr.last["siguiente"] = fila["id"]
        end
        if ((paginador.offset == 0 && num < paginador.per_page) || 
            (paginador.offset > 0 && num > 0 && 
             num <= paginador.per_page))
          if ultid != ''
            fila["anterior"] = ultid
          end
          arr.push(fila)
          puts ": #{fila[@coltexto]}"
        else
          puts fila[@coltexto]
        end
        ultid = fila["id"]
        num += 1
      end
      paginador.replace(arr)
      unless paginador.total_entries
        paginador.total_entries = @numresultados
      end
    end
  end

  def index
    authorize! :manage, Sal7711Gen::Articulo
    #byebug
    prepara_pagina 
    @muestraid = params[:muestraid].to_i
    #if params.to_h.count > 2
      # 2 params que siempre estan son controller y action si hay
      # más sería una consulta iniciada por usuario
    #   Sal7711Gen::Bitacora.a( request.remote_ip, current_usuario, 
    #                          'index', params)
    # end
    respond_to do |format|
      format.html { }
      format.json { head :no_content }
      format.js   { render 'resultados' }
    end
 end


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
