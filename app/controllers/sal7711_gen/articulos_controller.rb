# encoding: UTF-8

require 'sal7711_gen/concerns/controllers/articulos_controller'

module Sal7711Gen
  class ArticulosController < ApplicationController
 
    include Sal7711Gen::Concerns::Controllers::ArticulosController    


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
      @articulo.adjunto_descripcion = gen_descripcion_bd(@articulo)
      @articulo.save
    end

#    def create
#      byebug
#      authorize! :edit, Sal7711Gen::Articulo
#      @articulo = Sal7711Gen::Articulo.new(articulo_params)
#      ordena_articulo
#      create_gen(@articulo)
#    end

  end
end
