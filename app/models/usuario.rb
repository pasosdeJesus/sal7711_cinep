# encoding: UTF-8

require 'sal7711_gen/concerns/models/usuario'

class Usuario < ActiveRecord::Base

  include Sal7711Gen::Concerns::Models::Usuario

  devise :registerable, :confirmable
  campofecha_localizado :confirmed_at
  campofecha_localizado :fecharenovacion
  campofecha_localizado :locked_at
end
