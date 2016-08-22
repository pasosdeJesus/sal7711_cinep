# encoding: UTF-8

class Usuario < Sal7711Gen::Usuario
  devise :registerable, :confirmable

  validates_length_of :nusuario, maximum: 255
end
