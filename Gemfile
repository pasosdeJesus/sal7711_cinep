source 'https://rubygems.org'

#ruby "2.2.2"

# Rails (internacionalización)
gem "rails", '~> 5.1.0'
gem "rails-i18n"

# Postgresql
gem "pg"

gem 'mail_form'

gem 'tiny_tds', '~> 0.7'

gem 'puma'

# Colores en consola
gem "colorize"

# Para generar CSS
gem "sass"
gem "sass-rails"
#gem "compass-rails", git: "https://github.com/Compass/compass-rails.git", branch: "master"



# Cuadros de selección para búsquedas
gem 'chosen-rails'

# Dialogo modal
gem 'lazybox'

# Para convertir de tiff a jpg
#gem "rmagick"

gem "font-awesome-rails"
#
# Para generar PDF
gem "prawn"

# API JSON facil. Ver: https://github.com/rails/jbuilder
gem "jbuilder"

# Uglifier comprime recursos Javascript
gem "uglifier", '3.0.4'

# CoffeeScript para recuersos .js.coffee y vistas
gem "coffee-rails"

# jquery como librería JavaScript
gem "jquery-rails"

gem "jquery-ui-rails"

# Seguir enlaces más rápido. Ver: https://github.com/rails/turbolinks
gem "turbolinks"

# Ambiente de CSS
gem "twitter-bootstrap-rails"
gem "bootstrap-datepicker-rails"

# Formularios simples 
gem "simple_form"

# Formularios anidados (algunos con ajax)
gem "cocoon", git: "https://github.com/vtamara/cocoon.git"

# Autenticación y roles
gem "devise"
gem "devise-i18n"
gem "cancancan"
gem "bcrypt"

# Listados en páginas
gem "will_paginate"

# ICU con CLDR
gem 'twitter_cldr'

# Maneja adjuntos
gem "paperclip"

# Zonas horarias
gem "tzinfo"
gem "tzinfo-data"

# Motor de sistemas de información estilo Pasos de Jesús
gem 'sip', git: "https://github.com/pasosdeJesus/sip.git"
#gem 'sip', path: '../sip'

# Motor 
gem 'sal7711_gen', git: "https://github.com/pasosdeJesus/sal7711_gen.git"
#gem 'sal7711_gen', path: '../sal7711_gen'


# Los siguientes son para desarrollo o para pruebas con generadores
group :development do

  gem "minitest"

  #gem "minitest-reporters"
 
  # Depurar
  #gem 'byebug'

  # Consola irb en páginas con excepciones o usando <%= console %> en vistas
  gem 'web-console'
end

# Los siguientes son para pruebas y no tiene generadores requeridos en desarrollo
group :test do
  # Acelera ejecutando en fondo.  https://github.com/jonleighton/spring
  gem "spring"

  # https://www.relishapp.com/womply/rails-style-guide/docs/developing-rails-applications/bundler
  # Lanza programas para examinar resultados
  gem "launchy"

  gem 'rails-controller-testing'

  gem 'pry-rescue'
  gem 'pry-stack_explorer'

  gem 'meta_request'

  # Pruebas de regresión que no requieren javascript
  gem "capybara"
  
  # Envia resultados de pruebas desde travis a codeclimate
  #gem "codeclimate-test-reporter", require: nil
end


group :production do
  # Para despliegue
  gem "unicorn"

  # Requerido por heroku para usar stdout como bitacora
  gem "rails_12factor"
end


