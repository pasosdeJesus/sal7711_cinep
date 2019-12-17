# encoding: UTF-8

require 'sip/concerns/controllers/hogar_controller'

module Sip
  class HogarController < ApplicationController

    include Sip::Concerns::Controllers::HogarController

    def presentacion
      render 'presentacion', layout: false
    end
  end
end
