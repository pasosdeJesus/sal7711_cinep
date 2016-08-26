# encoding: UTF-8
class IpOrganizacion < ActiveRecord::Base

  belongs_to :organizacion, validate: true

  validates :organizacion_id, presence: true, allow_blank: false
  validates :ip, presence: true, allow_blank: false
end
