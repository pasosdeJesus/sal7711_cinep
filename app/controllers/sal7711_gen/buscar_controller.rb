# encoding: UTF-8
require_dependency "sal7711_gen/concerns/controllers/buscar_controller"

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
      "adjunto_descripcion"
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
      if !@client || @client.dead? || !@client.active?
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
      end
      r.do
      c="SELECT itemdata.itemnum, itemdata.itemname FROM itemdata 
      JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
      WHERE keyitem103.keyvaluedate>'#{Time.now.strftime("%Y/%m/%d")}';"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Fecha en el futuro en artículo #{fila['itemnum']}: #{fila['itemname']}"
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
      end
      r.do

      return cprob
    end

    def verifica_categorias_onbase
      cprob = ''
      c="SELECT itemdata.itemnum, itemname FROM itemdata 
      JOIN keyitem103 ON itemdata.itemnum=keyitem103.itemnum 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemdata.itemnum NOT IN (SELECT itemnum FROM keyxitem112);"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Falta primera categoria en artículo #{fila['itemnum']}: #{fila['itemname']}"
      end
      r.do
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

    def sincroniza
      @examinados = 0
      @procesados = 0
      @sinc = []
      @cprob = ''
      conecta_onbase
      if !@client.active?
        conecta_onbase
      end
      @cprob += verifica_fechas_onbase
      @cprob += verifica_departamentos_onbase
      @cprob += verifica_municipios_onbase
      @cprob += verifica_fuenteprensa_onbase
      @cprob += verifica_paginas
      @cprob += verifica_categorias
      return
      #return if @cprob != ''
      minitemnum = Sal7711Gen::Articulo.maximum(:onbase_itemnum) || 0
      maxitemnum = 870
      c="SELECT itemdata.itemnum AS itemnum, itemdata.itemname AS itemname,
          keyitem103.keyvaluedate AS fecha,
          keytable101.keyvaluechar AS fuenteprensa,
          keytable104.keyvaluechar AS pagina,
          keytable108.keyvaluechar AS departamento,
          keytable110.keyvaluechar AS municipio,
          keytable112.keyvaluechar AS cat1,
          keytable113.keyvaluechar AS cat2,
          keytable114.keyvaluechar AS cat3
          FROM itemdata 
          JOIN keyitem103 ON keyitem103.itemnum=itemdata.itemnum  
          JOIN keyxitem101 ON keyxitem101.itemnum = itemdata.itemnum
          JOIN keytable101 ON keyxitem101.keywordnum = keytable101.keywordnum 
          JOIN keyxitem104 ON keyxitem104.itemnum = itemdata.itemnum
          JOIN keytable104 ON keyxitem104.keywordnum = keytable104.keywordnum 
          JOIN keyxitem112 ON keyxitem112.itemnum = itemdata.itemnum
          JOIN keytable112 ON keyxitem112.keywordnum = keytable112.keywordnum 
          LEFT JOIN keyxitem108 ON keyxitem108.itemnum = itemdata.itemnum
          LEFT JOIN keytable108 ON keyxitem108.keywordnum = keytable108.keywordnum 
          LEFT JOIN keyxitem110 ON keyxitem110.itemnum = itemdata.itemnum
          LEFT JOIN keytable110 ON keyxitem110.keywordnum = keytable110.keywordnum 
          LEFT JOIN keyxitem113 ON keyxitem113.itemnum = itemdata.itemnum
          LEFT JOIN keytable113 ON keyxitem113.keywordnum = keytable113.keywordnum 
          LEFT JOIN keyxitem114 ON keyxitem114.itemnum = itemdata.itemnum
          LEFT JOIN keytable114 ON keyxitem114.keywordnum = keytable114.keywordnum 
          WHERE itemdata.itemnum < #{maxitemnum}
          AND itemname LIKE 'Prensa Cinep%' 
          AND keyitem103.keyvaluedate >= '1960-01-01'
          AND keyitem103.keyvaluedate <= '#{Time.now.strftime("%Y/%m/%d")}'
          ORDER BY itemnum"
      puts "OJO q=#{c}"
      result = @client.execute(c)
      puts "result.count=" + result.count.to_s
#      result.try(:each) do |fila|
#        itemnum = fila['itemnum']
#        if Sal7711Gen::Articulo.where(onbase_itemnum: itemnum).count == 0
#          itemname = it['itemname']
#          puts "itemname #{itemname}"
#          nart = Sal7711Gen::Articulo.new
#          nart.onbase_itemnum = itemnum
#          nart.adjunto_descripcion = itemname
#          nart.fecha = fila['fecha']
#          # Departamento
#          #byebug
#          dep = fila["departamento"]
#          if dep && dep.strip != ''
#            nart.departamento = Sip::Departamento.where("SUBSTRING(nombre FROM 1 FOR 45) = '#{dep.strip}'").first
#              # Municipio
#              mun=fila["municipio"]
#              nart.municipio = Sip::Municipio.where(
#                  id_departamento: nart.departamento_id).
#                  where("SUBSTRING(nombre FROM 1 FOR 45) = '#{mun.strip}'").first
#              end
#            end
#          end
#          
#
#          # Fuente
#          c2 = "SELECT keyvaluechar FROM keyxitem101, keytable101 WHERE
#          keyxitem101.keywordnum = keytable101.keywordnum AND
#          keyxitem101.itemnum = '#{itemnum}'"
#          r2 = @client.execute(c2)
#          if r2.count > 0
#            v2 = r2.first["keyvaluechar"]
#            r2.do
#            if v2 && v2.strip != ''
#              nart.fuenteprensa = Sip::Fuenteprensa.where("SUBSTRING(nombre FROM 1 FOR 45) = '#{v2.strip}'").first
#            end
#          else
#            @cprob += "<br>Elemento #{itemnum} no tiene Fuente"
#            r2.do
#          end
#
#          # Pagina
#          c2 = "SELECT keyvaluechar FROM keyxitem104, keytable104 WHERE
#          keyxitem104.keywordnum = keytable104.keywordnum AND
#          keyxitem104.itemnum = '#{itemnum}'"
#          r2 = @client.execute(c2)
#          if r2.count > 0
#            v2 = r2.first["keyvaluechar"]
#            r2.do
#            if v2 && v2.strip != ''
#              nart.pagina = v2.strip
#            end
#          else
#            @cprob += "<br>Elemento #{itemnum} no tiene Página"
#            r2.do
#          end
#          # Categorias, falta prio y antes cambiar tabla articulo_categoria para que tenga id
#          # Archivo descargar, reubicar y procesar
#          @sinc << itemname
#          @procesados += 1
#        end
#        @examinados += 1
#      end
#      #byebug
    end

    def prepara_pagina_comp(articulos, params)
      # R-3.6.2-2 El estado de un lote depende de la cantidad de imágenes 
      # por procesar (i) y la cantidad de artículo procesados (a). 
      # Es invariante que i+a>0. 
      # El estado es 
      #   "En espera" si a=0. 
      #   "En progreso" si a>0 y i>0. 
      #   "Procesado" si i=0.
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
      if params[:buscar] && params[:buscar][:lote] && params[:buscar][:lote] != ''
        pl = params[:buscar][:lote].to_i
        articulos = articulos.where('lote_id = ?', pl)
      end
      return articulos
    end

  end
end
