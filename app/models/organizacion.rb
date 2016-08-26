# encoding: UTF-8
class Organizacion < ActiveRecord::Base
  include Sip::Basica
  
  has_many :ip_organizacion, foreign_key: "organizacion_id", 
    dependent: :delete_all, class_name: 'IpOrganizacion'
  accepts_nested_attributes_for :ip_organizacion,
    allow_destroy: true, reject_if: :all_blank
  
  belongs_to :usuario, foreign_key: "usuarioip_id", 
    validate: true, class_name: 'Usuario'

  validates :nombre, presence: true, allow_blank: false
  validates :fechacreacion, presence: true, allow_blank: false
end
