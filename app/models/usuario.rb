# encoding: UTF-8

class Usuario < Sal7711Gen::Usuario
  devise :registerable, :confirmable
  campofecha_localizado :confirmed_at
  campofecha_localizado :fecharenovacion
  campofecha_localizado :locked_at
end
