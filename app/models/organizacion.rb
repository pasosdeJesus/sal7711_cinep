# encoding: UTF-8
class Organizacion < ActiveRecord::Base
  include Sip::Basica
  
  has_many :iporganizacion, foreign_key: "organizacion_id", 
    dependent: :delete_all, class_name: 'Iporganizacion', 
    validate: true
  accepts_nested_attributes_for :iporganizacion,
    allow_destroy: true, reject_if: :all_blank
 
  belongs_to :usuarioip, foreign_key: "usuarioip_id", 
    validate: true, class_name: 'Usuario'

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
  validates :usuarioip_id, presence: true, allow_blank: false

  mattr_accessor :fecharenovacion
  mattr_accessor :diasvigencia

  def fecharenovacion
    usuarioip_id ? usuarioip.fecharenovacion : ''
  end

  def diasvigencia
    usuarioip_id ? usuarioip.diasvigencia : ''
  end
end
