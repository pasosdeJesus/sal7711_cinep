class PoneRenovacionCinep < ActiveRecord::Migration[5.1]
  def up
    o = Organizacion.where(id: 1).take
    if o.diasvigencia.nil?
      o.diasvigencia = 36500
      o.fecharenovacion = '2017-09-20'
      o.save!
    end
  end
  def down
  end
end
