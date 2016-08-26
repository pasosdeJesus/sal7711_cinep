class Contacto < MailForm::Base
  attribute :nombre,      :validate => true
  attribute :correo,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :mensaje
  attribute :nickname,  :captcha  => true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "Formulario de Contacto Archivo de Prensa",
      :to => "vtamara@pasosdeJesus.org",
      :from => %("#{nombre}" <#{correo}>)
    }
  end
end
