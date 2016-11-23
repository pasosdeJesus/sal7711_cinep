# encoding: UTF-8
require_dependency "sal7711_gen/concerns/controllers/buscar_controller"
#require_dependency "paperclip/contet_type_detector.rb"


module Sal7711Gen
  class BuscarController < ApplicationController
    #skip_before_action :verify_authenticity_token, if: :autenticado_por_ip?
    # Necesario para EZ-Proxy, por lo mismo se requiere authorize en otros métodos

    def autenticado_por_ip?
      current_usuario && current_usuario.autenticado_por_ip
    end

    include Sal7711Gen::Concerns::Controllers::BuscarController
  
    include ActionView::Helpers::AssetUrlHelper

    # Conexión a base de datos
    @@hbase = {:username => ENV["USUARIO_HBASE"],
               :password => ENV["CLAVE_HBASE"],
               :host => ENV["IP_HBASE"], 
               :timeout => 30
    }
    # Conexión a directorio compartido con archivos
    @@parsmb = {
      domain: ENV['DOMINIO'],
      host: ENV['IP_HBASE'],
      share: ENV['CARPETA'],
      user: ENV['USUARIO_DOMINIO'],
      password: ENV['CLAVE_DOMINIO'],
      port: 445
    }

    def orden_articulos
      "fecha, adjunto_descripcion"
    end

    def autentica_especial
      return false
#      puts "OJO ipx, request=", request.inspect;
#      org = ::Organizacion.joins(:ip_organizacion)
#        .where('?<<=ip', request.remote_ip).take
#      if !current_usuario
#        nips = ::IpOrganizacion.where('? <<= ip', request.remote_ip).
#          count('organizacion_id', distinct: true)
#        if nips === 0
#          if (current_usuario && ::Organizacion.
#              where('usuarioip_id=?', current_usuario.id).
#              count('*') > 0)
#            # Si la organización ya no se autentica por IP se termina
#            # sesión de usuario
#            sign_out(current_usuario)
#          end
#          return false
#        elsif nips > 1
#          ::Ability::ultimo_error_aut = 'IP coincide con varias organizaciones'
#          puts "** Error: ", ::Ability::ultimo_error_aut 
#          return false
#        else
#          if !org.usuarioip_id
#            ::Ability.ultimo_error_aut = 'Organización sin Usuario IP'
#            puts "** Error: ", ::Ability::ultimo_error_aut 
#            return false
#          end
#          us = ::Usuario.find(org.usuarioip_id)
#          sign_in(us) #, bypass: true#, store: false
#          #byebug
#          current_usuario.autenticado_por_ip = true
#          current_usuario.save!
#          return true;
#        end
#      end
#      if current_usuario && current_usuario.autenticado_por_ip
#        if org.opciones_url_nombre_cif
#          Rails.configuration.action_mailer.default_url_options[:host] = 
#            org.opciones_url_nombre_cif
#        end
#        if org.opciones_url_puerto_cif
#          Rails.configuration.action_mailer.default_url_options[:port] = 
#            org.opciones_url_puerto_cif
#        end
#        if org.opciones_url_nombre_nocif
#          Rails.configuration.x.serv_nocif[:host] = 
#            org.opciones_url_nombre_nocif
#        end
#        if org.opciones_url_puerto_nocif
#          Rails.configuration.x.serv_nocif[:port] = 
#            org.opciones_url_puerto_nocif
#        end
#        puts "Rails.configuration.action_mailer.default_url_options=",
#          Rails.configuration.action_mailer.default_url_options
#        puts "Rails.configuration.x.serv_nocif=",
#          Rails.configuration.x.serv_nocif
#      end
    end


    def conecta_onbase
      #if !@client || @client.dead? || !@client.active?
      if !@client || !@client.active?
        @client = TinyTds::Client.new(@@hbase)
        @client.execute("USE OnBase").do;
      end
      if @client.dead?
        puts "dead"
        byebug
      end
      if !@client.active?
        puts "no active";
        byebug
      end
    end
 
   @regprob = [] 
    def incregprob(itemnum)
          @regprob[itemnum] = 
            @regprob[itemnum].nil? ? 1 : 
            @regprob[itemnum] + 1 
    end

    def verifica_fechas_onbase
      cprob = ''
      
      # Estas por lo visto saca articulos usados internamente por
      # ONBASE para indexar, y no se convierten
      #c="SELECT itemnum, itemname FROM itemdata 
      #WHERE itemname LIKE 'Prensa Cinep%' 
      #AND itemnum NOT IN (SELECT itemnum FROM keyitem103);"
      #r = @client.execute(c)
      #r.try(:each) do |fila|
      #    cprob += "<br>Falta fecha en artículo #{fila['itemnum']}: #{fila['itemname']}"
      #end
      #r.do
      c="SELECT itemdata.itemnum, itemdata.itemname FROM itemdata 
      JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
      WHERE keyitem103.keyvaluedate<'1960-01-01';"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Fecha muy antigua en artículo #{fila['itemnum']}: #{fila['itemname']}"
          incregprob(fila['itemnum'].to_i)
      end
      r.do
      c="SELECT itemdata.itemnum, itemdata.itemname FROM itemdata 
      JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
      WHERE keyitem103.keyvaluedate>'#{Time.now.strftime("%Y/%m/%d")}';"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Fecha en el futuro en artículo #{fila['itemnum']}: #{fila['itemname']}"
          incregprob(fila['itemnum'].to_i)
      end
      r.do

      return cprob 
    end
 
    def verifica_fuenteprensa_onbase
      cprob = ''
      c="SELECT itemdata.itemnum, itemname FROM itemdata 
      JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemdata.itemnum NOT IN (SELECT itemnum FROM keyxitem101);"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Falta fuente en artículo #{fila['itemnum']}: #{fila['itemname']}"
          incregprob(fila['itemnum'].to_i)
      end
      r.do

      c="SELECT DISTINCT keyvaluechar FROM keytable101;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nf = fila["keyvaluechar"].strip
          if Sip::Fuenteprensa.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nf}'").count == 0
            cprob += "<br>Fuente #{nf} de SQL Server no aparece en PostgreSQL"
          end
        end
      end


      return cprob
    end

    def verifica_paginas_onbase
      cprob = ''
      c="SELECT itemdata.itemnum, itemname FROM itemdata 
      JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemdata.itemnum NOT IN (SELECT itemnum FROM keyxitem104);"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Falta página en artículo #{fila['itemnum']}: #{fila['itemname']}"
          incregprob(fila['itemnum'].to_i)
      end
      r.do

      return cprob
    end

    def verifica_categorias_onbase
      cprob = ''
      if false
        c="SELECT itemdata.itemnum, itemname FROM itemdata 
      JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemdata.itemnum NOT IN (SELECT itemnum FROM keyxitem112);"
        r = @client.execute(c)
        r.try(:each) do |fila|
          cprob += "<br>Falta primera categoria en artículo #{fila['itemnum']}: #{fila['itemname']}"
          incregprob(fila['itemnum'].to_i)
        end
        r.do
      end
      sep = ""
      lcat = ""
      Sal7711Gen::Categoriaprensa.all.each do |cat|
        lcat += "#{sep}'#{cat.codigo}'"
        sep = ", "
      end

      c = "SELECT keyvaluechar, itemdata.itemnum, itemname 
           FROM keyxitem112
           JOIN keytable112 ON keyxitem112.keywordnum=keytable112.keywordnum
           JOIN itemdata ON itemdata.itemnum=keyxitem112.itemnum
           JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
           WHERE keytable112.keyvaluechar NOT IN (#{lcat})
           ORDER BY 1;"
      puts c
      #exit 1

      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nc = fila["keyvaluechar"].strip
          cprob += "<br>Categoria 1 #{nc} errada, en artículo #{fila['itemnum']}: #{fila['itemname']}"
          incregprob(fila['itemnum'].to_i)
        end
      end

      c = "SELECT keyvaluechar, itemdata.itemnum, itemname 
           FROM keyxitem113
           JOIN keytable113 ON keyxitem113.keywordnum=keytable113.keywordnum
           JOIN itemdata ON itemdata.itemnum=keyxitem113.itemnum
           JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
           WHERE keytable113.keyvaluechar NOT IN (#{lcat})
           ORDER BY 1;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nc = fila["keyvaluechar"].strip
          cprob += "<br>Categoria 2 #{nc} errada, en artículo #{fila['itemnum']}: #{fila['itemname']}"
          incregprob(fila['itemnum'].to_i)
        end
      end

      c = "SELECT keyvaluechar, itemdata.itemnum, itemname 
           FROM keyxitem114
           JOIN keytable114 ON keyxitem114.keywordnum=keytable114.keywordnum
           JOIN itemdata ON itemdata.itemnum=keyxitem114.itemnum
           JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
           WHERE keytable114.keyvaluechar NOT IN (#{lcat})
           ORDER BY 1;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nc = fila["keyvaluechar"].strip
          cprob += "<br>Categoria 3 #{nc} errada, en artículo #{fila['itemnum']}: #{fila['itemname']}"
          incregprob(fila['itemnum'].to_i)
        end
      end

      return cprob
    end

    def verifica_departamentos_onbase
      cprob = ''
      ds = Sip::Departamento.all.where(id_pais: 170).
        where("nombre != 'EXTERIOR'")
      ds.each do |d|
        puts d.nombre[0..44]
        c="SELECT COUNT(*) AS cuenta FROM keytable108 WHERE keyvaluechar='#{d.nombre[0..44]}';"
        cuentar = @client.execute(c)
        @numregistros = cuentar.first["cuenta"]
        if @numregistros != 1
          cprob += "<br>Departamento #{d.nombre} aparece #{@numregistros} veces"
        end
      end
      c="SELECT keyvaluechar FROM keytable108;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nd = fila["keyvaluechar"].strip
          if Sip::Departamento.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nd}'").count == 0
            cprob += "<br>Departamento #{nd} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      return cprob
    end 

    def verifica_municipios_onbase
      cprob = ''
      c="SELECT keyvaluechar FROM keytable110;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nd = fila["keyvaluechar"].strip
          if Sip::Municipio.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nd}'").count == 0
            cprob += "<br>Municipio #{nd} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      return cprob
    end 

    def descarga_onbase(rutaremota, prefijoruta)
      authorize! :read, Sal7711Gen::Articulo
      #conecta_onbase
      rutaconv = rutaremota.gsub("\\", "/")
      rlocal = prefijoruta + File.basename(rutaconv)
      puts "rutaremota=#{rutaremota}, rlocal=#{rlocal}"
      if (!File.exists? rlocal)
        cmd="smbget -o #{rlocal} -p '#{ENV['CLAVE_DOMINIO']}' -w #{ENV['DOMINIO']} -u #{ENV['USUARIO_DOMINIO']} -v smb://#{ENV['IP_HBASE']}/#{ENV['CARPETA']}/#{rutaconv}"
        cmdl = cmd.gsub(ENV['CLAVE_DOMINIO'], '*****')
        logger.info "Ejecutando #{cmdl}"
        r=`#{cmd}`
        logger.info "Resultado: ---- #{r} ----"
      end
      return rlocal
    end



    # grupof Son los qeu faltan de [minitemnum, maxitemnum)
    # grupoe son los que ya estan de [minitemnum, maxitemnum)
    def procesa_grupo(minitemnum, maxitemnum, grupof=[], grupoe=[])
      conecta_onbase
      if !@client.closed?
        @client.close
      end
      @client = TinyTds::Client.new(@@hbase)
      @client.execute("USE OnBase").do;
     
      # Ya estan todos
      if grupof.length == 0 && grupoe.length > 0
        puts "No faltan"
        return
      end
      if grupof.length > 0
        cadestan = "AND itemdata.itemnum IN (" + grupof.join(', ') + ")"
#      else
#        consestan = "SELECT onbase_itemnum FROM sal7711_gen_articulo 
#          WHERE onbase_itemnum < #{maxitemnum}
#          AND onbase_itemnum >= #{minitemnum} ORDER BY 1"
#          estan = ActiveRecord::Base.connection.select_all consestan
#          cadestan = estan.to_a.map {|v| v['onbase_itemnum']}.join(', ')
#
#          if cadestan.length > 0
#            cadestan = "AND itemdata.itemnum NOT IN (" + cadestan + ")"
#          end
      end
      fbuenos = "FROM itemdata 
          JOIN itemdatapage ON itemdata.itemnum=itemdatapage.itemnum 
          JOIN keyitem103 ON keyitem103.itemnum=itemdata.itemnum   
          JOIN keyxitem101 ON keyxitem101.itemnum = itemdata.itemnum
          JOIN keytable101 ON keyxitem101.keywordnum = keytable101.keywordnum 
          JOIN keyxitem104 ON keyxitem104.itemnum = itemdata.itemnum
          JOIN keytable104  ON keyxitem104.keywordnum = keytable104.keywordnum 
          LEFT JOIN keyxitem112 ON keyxitem112.itemnum = itemdata.itemnum
          LEFT JOIN keytable112  ON keyxitem112.keywordnum = keytable112.keywordnum 
          LEFT JOIN keyxitem108 ON keyxitem108.itemnum = itemdata.itemnum
          LEFT JOIN keytable108  ON 
            keyxitem108.keywordnum = keytable108.keywordnum 
          LEFT JOIN keyxitem110 ON keyxitem110.itemnum = itemdata.itemnum
          LEFT JOIN keytable110  ON 
            keyxitem110.keywordnum = keytable110.keywordnum 
          LEFT JOIN keyxitem113 ON keyxitem113.itemnum = itemdata.itemnum
          LEFT JOIN keytable113  ON 
            keyxitem113.keywordnum = keytable113.keywordnum 
          LEFT JOIN keyxitem114 ON keyxitem114.itemnum = itemdata.itemnum
          LEFT JOIN keytable114  ON 
            keyxitem114.keywordnum = keytable114.keywordnum 
          WHERE keyitem103.keyvaluedate >= '1960-01-01'
          AND keyitem103.keyvaluedate <= '#{Time.now.strftime("%Y-%m-%d")}'
          AND itemname LIKE 'Prensa Cinep%' "

      c="SELECT itemdata.itemnum AS itemnum, itemdata.itemname AS itemname,
          itemdata.batchnum AS batchnum,
          itemdatapage.filepath AS filepath,
          keyitem103.keyvaluedate AS fecha,
          keytable101.keyvaluechar AS fuenteprensa,
          keytable104.keyvaluechar AS pagina,
          keytable108.keyvaluechar AS departamento,
          keytable110.keyvaluechar AS municipio,
          keytable112.keyvaluechar AS cat1,
          keytable113.keyvaluechar AS cat2,
          keytable114.keyvaluechar AS cat3 #{fbuenos}
          AND itemdata.itemnum < #{maxitemnum}
          AND itemdata.itemnum >= #{minitemnum}
          #{cadestan}
          ORDER BY itemnum "
      puts "OJO q=#{c}"
      numreg = 0
      # Resultado a colchon en memoria
      colchon = []
      result = @client.execute(c)
      result.try(:each) do |fila|
        colchon << fila
      end
      result.cancel
      @client.close

      if colchon.length == 0
        puts "De los que faltan en base local no hay registros completos en remota"
        return
      end
      puts "Procesando colchon"
      # Se procesa colchon
      colchon.each do |fila|
        numreg += 1
        itemnum = fila['itemnum']
        puts "numreg=#{numreg}, itemnum=#{itemnum}"
        if grupoe.index(itemnum).nil?
          itemname = fila['itemname']
          puts "itemname #{itemname}"
          nart = Sal7711Gen::Articulo.new
          if !nart
            @cprob += "<br>No pudo crearse articulo"
            next
          end
          nart.onbase_itemnum = itemnum
          nart.adjunto_descripcion = itemname
          nart.fecha = fila['fecha']
          # Lote
          nlote = fila['batchnum'] 
          if nlote 
            if !Lote.exists?(nlote.to_i)
              l = Lote.new
              l.id = nlote.to_i
              l.usuario = current_usuario
              l.nombre = nart.fecha
              l.save!
            end
            nart.lote_id = nlote
          end

          # Departamento
          #          #byebug
          dep = fila["departamento"]
          if dep && dep.strip != ''
            nart.departamento = Sip::Departamento.where("SUBSTRING(nombre FROM 1 FOR 45) = '#{dep.strip}'").first
            # Municipio
            mun=fila["municipio"]
            if mun && mun.strip != ''
              nart.municipio = Sip::Municipio.where(
                id_departamento: nart.departamento_id).
                where("SUBSTRING(nombre FROM 1 FOR 45) = '#{mun.strip}'").first
            end
          end

          # Fuente de prensa
          f = fila['fuenteprensa']
          if !f || f.strip == ''
            @cprob += "<br>Elemento #{itemnum} no tiene fuente (saltando)"
            incregprob(itemnum)
            next
          end
          nart.fuenteprensa = Sip::Fuenteprensa.where("SUBSTRING(nombre FROM 1 FOR 45) = '#{f.strip}'").first
          if nart.fuenteprensa.nil?
            @cprob += "<br>Elemento #{itemnum} tiene fuente errada #{f} (saltando)"
            incregprob(itemnum)
            next
          end

          # Pagina
          p = fila['pagina']
          if !p || p.strip == ''
            @cprob += "<br>Elemento #{itemnum} no tiene página (saltando)"
            incregprob(itemnum)
            next
          end
          nart.pagina = p

          # Adjunto
          nart.created_at = nart.fecha
          nart.updated_at = Time.now

          nart.adjunto_file_name = "J"
          nart.adjunto_content_type = "J"
          nart.adjunto_file_size = 0
          nart.adjunto_updated_at = Time.now
          nart.save

          prefijoruta = Rails.root.join(
            'public', Rails.application.config.x.url_colchon)
          rlocal = descarga_onbase(fila['filepath'].rstrip,
                                   prefijoruta.to_s + "/")

          if !File.exists?(rlocal)
            @cprob += "<br>No pudo descargarse archivo #{rlocal}"
            next
          end
          File.open(rlocal, "r") do |arc|
            nart.adjunto = arc
            nart.save
          end

          # Categorias
          (1..3).each do |ncat|
            ccat = fila['cat' + ncat.to_s]
            if !ccat || ccat.strip == ''
              if ncat == 1
                @cprob += "<br>Elemento #{itemnum} no tiene categoria 1"
                incregprob(itemnum)
              end
            else
              ccat.strip!
              cat = Sal7711Gen::Categoriaprensa.where(codigo: ccat).first
              if !cat
                @cprob += "<br>Elemento #{itemnum} tiene categoria #{ncat} " +
                  "errada: #{ccat} (ignorando)"
                incregprob(itemnum)
              else
                cp = Sal7711Gen::ArticuloCategoriaprensa.new(
                  articulo_id: nart.id, categoriaprensa_id: cat.id, orden: ncat)
                cp.save
              end
            end
          end

          nart.adjunto_descripcion = 
            Sal7711Gen::ArticulosController.gen_descripcion_bd(nart)
          nart.save

          @sinc << itemname
          @procesados += 1
        end
        @examinados += 1
      end
      #conecta_onbase
    end

    def sincroniza_onbase
      @examinados = 0
      @procesados = 0
      @sinc = []
      @cprob = ''
      conecta_onbase
      if !@client.active?
        conecta_onbase
      end
      @regprob = []
      if params.to_unsafe_h["nover"].nil?
        @cprob += verifica_fechas_onbase
        @cprob += verifica_departamentos_onbase
        @cprob += verifica_municipios_onbase
        @cprob += verifica_fuenteprensa_onbase
        @cprob += verifica_paginas_onbase
        @cprob += verifica_categorias_onbase
      end
      @numregprob = @regprob.reject(&:nil?).count

      #return
      #return if @cprob != ''
#      minitemnum = Sal7711Gen::Articulo.maximum(:onbase_itemnum) || 0
#      maxitemnum = 1870

      # No me ha funcioando
      # r = @client.execute('SELECT MAX(itemnum) FROM itemdata;')
      #maxmax = r.first['max']
      maxmax=700000
      
      pasada = 0
      deltaitemnum = 1000
      minitemnum = 1 # Todos los anteriores a este han sido procesados
      maxitemnum = minitemnum + deltaitemnum
      
      # Al intentar toda la consulta se presentaron errores Read Failed
      # Tuvimos que procesar en lotes 
      @numexiste = 0
      loop do
        pasada += 1
        cidse = ActiveRecord::Base.connection.execute(
          "SELECT DISTINCT onbase_itemnum FROM sal7711_gen_articulo WHERE
           onbase_itemnum >= #{minitemnum} AND
           onbase_itemnum < #{maxitemnum}
           ORDER BY 1");
        idse = cidse.to_a.map {|a| a['onbase_itemnum']}
        @numexiste += idse.length
        i = 0
        idsf = []
        for n in minitemnum..maxitemnum-1
          if i < idse.length && idse[i] == n then
            i += 1
          else
            idsf << n
          end
        end
        #byebug
        procesa_grupo(minitemnum, maxitemnum, idsf, idse)
        break if maxitemnum > maxmax
        minitemnum += deltaitemnum
        maxitemnum += deltaitemnum
      end # loop

    end

    def prepara_pagina_comp(articulos, params)
      if params[:buscar] && params[:buscar][:lote] && 
        params[:buscar][:lote] != ''
        pl = params[:buscar][:lote].to_i
        articulos = articulos.where('lote_id = ?', pl)
      elsif params.to_unsafe_h[:buscar].nil? ||
        params.to_unsafe_h[:buscar].count == 0
        #byebug
        articulos = articulos.where('1=2')
      end
      return articulos
    end


    # Resultado de aplicar filtro
    def index
      autentica_especial
      authorize! :read, Sal7711Gen::Articulo
      prepara_meses
      @muestraid = params[:muestraid].to_i
      if params.to_unsafe_h.count > 2
        # 2 params que siempre estan son controller y action si hay
        # más sería una consulta iniciada por usuario
        prepara_pagina
        Sal7711Gen::Bitacora.a( request.remote_ip, current_usuario, 
                               'index', params)
      end
      respond_to do |format|
        format.html { }
        format.json { head :no_content }
        format.js   { render 'resultados' }
      end
    end
        
  end
end
