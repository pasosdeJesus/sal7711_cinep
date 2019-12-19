# encoding: UTF-8

require 'sip/concerns/controllers/hogar_controller'

module Sip
  class HogarController < ApplicationController

    include Sip::Concerns::Controllers::HogarController

    def presentacion
      render 'presentacion', layout: false
    end

    def calcular
      render 'calcular', layout: 'application'
    end

    def cotizar 
      render 'cotizar', layout: 'application'
    end

  end
end
