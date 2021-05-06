require_relative 'boot'
require 'rails/all'

# Requiere gemas listas en el Gemfile, incluyendo las
# limitadas a :test, :development, o :production.
Bundler.require(*Rails.groups)

module Sal7711
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    #config.load_defaults 6.0
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'America/Bogota'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :es

    config.active_record.schema_format = :sql

    config.hosts <<  ENV.fetch('CONFIG_HOSTS', 'defensor.info').downcase

    config.relative_url_root = ENV.fetch('RUTA_RELATIVA', "/")

    # sip
    config.x.formato_fecha = 'dd-mm-yyyy'

    #sal7711
    config.x.url_colchon = ENV.fetch(
      'SAL7711_COLCHON_ARTICULOS', 'colchon-articulos')

  end
end
