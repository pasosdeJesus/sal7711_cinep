# encoding: UTF-8

module Sal7711Gen
  class Consultausuario 
    include ActiveModel::Model

    attr_accessor :fechaini
    attr_accessor :fechafin
    attr_accessor :organizacion_id

    #belongs_to :organizacion, class_name: '::Organizacion', 
    #  foreign_key: 'organizacion_id'

    validate :fechas_ordenadas
    def fechas_ordenadas
      if fechaini && fechafin && fechaini > fechafin
        errors.add(:fechafin, 
                   "La fecha final debe ser posterior a la de inicio")
      end
    end

  end
end
