# encoding: UTF-8

require 'sal7711_gen/concerns/models/articulo'

module Sal7711Gen
  class Articulo < ActiveRecord::Base
    include Sal7711Gen::Concerns::Models::Articulo

    belongs_to :lote, foreign_key: "lote_id",
      validate: true, class_name: "::Lote"

    validates :fecha, presence: true
    validates :fuenteprensa_id, presence: true
    validates :pagina, presence: true, length: { maximum: 20 }
  end
end
