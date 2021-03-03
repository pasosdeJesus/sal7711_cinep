source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'bcrypt'

gem 'bigdecimal'

gem 'bootsnap', '>=1.1.0', require: false

gem 'cancancan'

gem 'cocoon', git: 'https://github.com/vtamara/cocoon.git'

gem 'coffee-rails' , '>= 5.0.0' # CoffeeScript para recuersos .js.coffee y vistas

gem 'devise' , '>= 4.7.3' # Autenticación 

gem 'devise-i18n', '>= 1.9.2'

gem 'jbuilder' # API JSON facil. Ver: https://github.com/rails/jbuilder

gem 'lazybox' # Dialogo modal

gem 'mail_form', '>= 1.9.0'

gem 'nokogiri', '>=1.11.1'

gem 'paperclip' # Maneja adjuntos

gem 'pg' # Postgresql

gem 'prawn' # Para generar PDF

gem 'puma'

gem 'rails', '~> 6.0.3.5'

gem 'rails-i18n', '>= 6.0.0'

gem 'sassc-rails' , '>= 2.1.2' # Para generar CSS

gem 'simple_form' , '>= 5.0.3' # Formularios simples 

gem 'tiny_tds'

gem 'twitter_cldr' # ICU con CLDR

gem 'tzinfo' # Zonas horarias

gem 'webpacker', '>= 5.2.1'

gem 'will_paginate' # Listados en páginas


#####
# Motores que se sobrecargan vistas (deben ponerse en orden de apilamiento 
# lógico y no alfabetico como las gemas anteriores) 

gem 'sip', # Motor generico
  git: 'https://github.com/pasosdeJesus/sip.git'
  #path: '../sip'

gem 'sal7711_gen', # Motor de archivo de prensa
  git: 'https://github.com/pasosdeJesus/sal7711_gen.git'
  #path: '../sal7711_gen'


group :development, :test do

  #gem 'byebug', platform: :mri # Depurar

  gem 'colorize' # Colores en consola

end


group :development do

  gem 'web-console' , '>= 4.1.0' # Consola irb en páginas 

end


group :test do

  gem 'capybara'

  gem 'minitest'

  gem 'minitest-reporters'
 
  gem 'selenium-webdriver'

  gem 'simplecov', '<0.18'

  gem 'spring'
  
end


group :production do
  
  gem 'unicorn' # Para despliegue

end


