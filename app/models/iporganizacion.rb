# encoding: UTF-8
class Iporganizacion < ActiveRecord::Base

  belongs_to :organizacion, validate: true

  attr_accessor :ipcadena 
  
  def ipcadena
    self.ip.to_s
  end

  def ipcadena=(val)
    self.ip = val
  end

  validates :organizacion_id, presence: true, allow_blank: false
  validates :ip, presence: true, allow_blank: false, 
    uniqueness: { scope: :organizacion_id }

  def presenta_nombre
    ipcadena
  end
end
