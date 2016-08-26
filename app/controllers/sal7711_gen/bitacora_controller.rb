# encoding: UTF-8

require 'sal7711_gen/concerns/controllers/bitacora_controller'

module Sal7711Gen
  class BitacoraController < ApplicationController
 
    include Sal7711Gen::Concerns::Controllers::BitacoraController

    # Prepara una página de resultados
    def usuario
      if !current_usuario
        authorize! :buscar, :index
      end
      @consultas = Bitacora.all.where(
        usuario_id: current_usuario.id,
        operacion: 'index').order('fecha desc').limit(@@porpag)

      respond_to do |format|
        format.html { render partial: 'consultausuario' }
        format.json { head :no_content }
        format.js   { render partial: 'consultausuario' }
      end
    end

    def admin
      @usuarioscons = Sal7711Gen::Bitacora.connection.select_rows(
        "SELECT nusuario, count(*) FROM sal7711_gen_bitacora 
          JOIN usuario ON usuario_id=usuario.id WHERE
          operacion = 'index' GROUP BY 1"
      )
      @totconsultas = Sal7711Gen::Bitacora.where(operacion: 'index').all.count
    end
 
    def tiempo
      @fechaini = (Date.today - 1).to_s
      @fechafin = Date.today.to_s
      tini = Time.parse(@fechaini +  " 00:00") #Tiempo local
      tfin = Time.parse(@fechafin +  " 23:59")
      @intervalo = 60 # En segundos
      c = "SELECT nusuario, operacion, fecha FROM sal7711_gen_bitacora 
          JOIN usuario ON usuario_id=usuario.id WHERE
          fecha>='#{tini.getgm}' and fecha<='#{tfin.getgm}' ORDER BY fecha DESC"
      filas = Sal7711Gen::Bitacora.connection.select_rows(c)
      usuarios = {}
      op_index = {}
      op_mostraruno = {}
      filas.each do |f|
        # Base retorna tiempo en UTC
        i =  (Time.parse(f[2] + " UTC").to_i - tini.to_i) / @intervalo
        i = i.to_i
        if (usuarios[i]) 
          usuarios[i].add(f[0])
        else 
          usuarios[i] = Set.new [f[0]]
        end
        op_index[i] = 0 if !op_index[i]
        op_index[i] += 1 if  f[1] == 'index'
        op_mostraruno[i] = 0 if !op_mostraruno[i]
        op_mostraruno[i] += 1 if  f[1] == 'mostraruno'
      end
      @tiempocons = []
      usuarios.each do |i, cn| 
       @tiempocons << [Time.at(tini.to_i + i*@intervalo).to_s, cn.count, op_index[i], op_mostraruno[i]]
      end
    end
  
  end
end
