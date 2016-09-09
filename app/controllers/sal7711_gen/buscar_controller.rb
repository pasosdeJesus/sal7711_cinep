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
    
    def autentica_especial
      return false
      puts "OJO ipx, request=", request.inspect;
      org = ::Organizacion.joins(:ip_organizacion)
        .where('?<<=ip', request.remote_ip).take
      if !current_usuario
        nips = ::IpOrganizacion.where('? <<= ip', request.remote_ip).
          count('organizacion_id', distinct: true)
        if nips === 0
          if (current_usuario && ::Organizacion.
              where('usuarioip_id=?', current_usuario.id).
              count('*') > 0)
            # Si la organización ya no se autentica por IP se termina
            # sesión de usuario
            sign_out(current_usuario)
          end
          return false
        elsif nips > 1
          ::Ability::ultimo_error_aut = 'IP coincide con varias organizaciones'
          puts "** Error: ", ::Ability::ultimo_error_aut 
          return false
        else
          if !org.usuarioip_id
            ::Ability.ultimo_error_aut = 'Organización sin Usuario IP'
            puts "** Error: ", ::Ability::ultimo_error_aut 
            return false
          end
          us = ::Usuario.find(org.usuarioip_id)
          sign_in(us) #, bypass: true#, store: false
          #byebug
          current_usuario.autenticado_por_ip = true
          current_usuario.save!
          return true;
        end
      end
      if current_usuario && current_usuario.autenticado_por_ip
        if org.opciones_url_nombre_cif
          Rails.configuration.action_mailer.default_url_options[:host] = 
            org.opciones_url_nombre_cif
        end
        if org.opciones_url_puerto_cif
          Rails.configuration.action_mailer.default_url_options[:port] = 
            org.opciones_url_puerto_cif
        end
        if org.opciones_url_nombre_nocif
          Rails.configuration.x.serv_nocif[:host] = 
            org.opciones_url_nombre_nocif
        end
        if org.opciones_url_puerto_nocif
          Rails.configuration.x.serv_nocif[:port] = 
            org.opciones_url_puerto_nocif
        end
        puts "Rails.configuration.action_mailer.default_url_options=",
          Rails.configuration.action_mailer.default_url_options
        puts "Rails.configuration.x.serv_nocif=",
          Rails.configuration.x.serv_nocif
      end
    end

    def verifica_fuenteprensa
      cprob = ''
      c="SELECT itemnum, itemname FROM itemdata 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemnum NOT IN (SELECT itemnum FROM keyxitem101);"
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

    def verifica_paginas
      cprob = ''
      c="SELECT itemnum, itemname FROM itemdata 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemnum NOT IN (SELECT itemnum FROM keyxitem104);"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Falta página en artículo #{fila['itemnum']}: #{fila['itemname']}"
      end
      r.do

      return cprob
    end

    def verifica_categorias
      cprob = ''
      c="SELECT itemnum, itemname FROM itemdata 
      WHERE itemname LIKE 'Prensa Cinep%' 
      AND itemnum NOT IN (SELECT itemnum FROM keyxitem112);"
      r = @client.execute(c)
      r.try(:each) do |fila|
          cprob += "<br>Falta primera categoria en artículo #{fila['itemnum']}: #{fila['itemname']}"
      end
      r.do

      c="SELECT DISTINCT keyvaluechar FROM keytable112;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nc = fila["keyvaluechar"].strip
          if Sip::Fuenteprensa.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nc}'").count == 0
            cprob += "<br>Categoria 1 #{nc} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      c="SELECT DISTINCT keyvaluechar FROM keytable113;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nc = fila["keyvaluechar"].strip
          if Sip::Fuenteprensa.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nc}'").count == 0
            cprob += "<br>Categoria 2 #{nc} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      c="SELECT DISTINCT keyvaluechar FROM keytable114;"
      r = @client.execute(c)
      r.try(:each) do |fila|
        if fila['keyvaluechar'] && fila['keyvaluechar'].strip != ''
          nc = fila["keyvaluechar"].strip
          if Sip::Fuenteprensa.
            where("SUBSTRING(nombre FROM 1 FOR 45) = '#{nc}'").count == 0
            cprob += "<br>Categoria 3 #{nc} de SQL Server no aparece en PostgreSQL"
          end
        end
      end

      return cprob
    end

    def verifica_departamentos
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

    def verifica_municipios
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
      conecta
      if !@client.active?
        conecta
      end
      @cprob += verifica_fechas
      @cprob += verifica_departamentos
      @cprob += verifica_municipios
      @cprob += verifica_fuenteprensa
      @cprob += verifica_paginas
      @cprob += verifica_categorias
    end

    def prepara_pagina_comp(articulos, params)
      if params[:buscar] && params[:buscar][:lote] && params[:buscar][:lote] != ''
        pl = params[:buscar][:lote].to_i
        articulos = articulos.where('lote_id = ?', pl)
      end
      return articulos
    end

  end
end
