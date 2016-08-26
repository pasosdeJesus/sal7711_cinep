# encoding: UTF-8
module Sal7711Gen
  module Admin
    class CategoriasprensaController < Sip::Admin::BasicasController
      before_action :set_categoriaprensa, 
        only: [:show, :edit, :update, :destroy]
      #load_and_authorize_resource  class: Sal7711Gen::Categoriaprensa
      # Categorias son públicas
      
      def clase 
        "Sal7711Gen::Categoriaprensa"
      end

      def camponombre
        :codigo
      end

      def set_categoriaprensa
        @basica = Categoriaprensa.find(params[:id])
      end

      def atributos_index
        [
          "id", "codigo", "nombre", "supracategoria", 
          "observaciones", "fechacreacion", 
          "fechadeshabilitacion"
        ]
      end

      def categoriaprensa_params
        params.require(:categoriaprensa).permit(*atributos_form)
      end

    end
  end
end
