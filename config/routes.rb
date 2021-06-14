# encoding: UTF-8

Rails.application.routes.draw do

  rutarel = ENV.fetch('RUTA_RELATIVA', 'cor1440/')
  scope rutarel do 
    devise_scope :usuario do
      #get 'sign_out' => 'devise/sessions#destroy'
      get 'sign_out' => 'sessions#destroy', as: :sign_out
      get 'usuarios/sign_in' => 'sessions#new', as: :sign_in
      get 'sign_up' => 'registrations#new', as: :sign_up

      #root 'sessions#new' 

      # El siguiente para superar mala generación del action en el formulario
      # cuando se autentica mal (genera 
      # /puntomontaje/puntomontaje/usuarios/sign_in )
      if (Rails.configuration.relative_url_root != '/') 
        ruta = File.join(Rails.configuration.relative_url_root, 
                         'usuarios/sign_in')
        post ruta, to: 'devise/sessions#create'
      end
    end
    devise_for :usuarios, module: :devise, 
      controllers: { registrations: "registrations" }
    #devise_for :usuarios, :skip => [:registrations], module: :devise
    as :usuario do
      get 'usuarios/edit' => 'devise/registrations#edit', 
        :as => 'editar_registro_usuario'    
      put 'usuarios/:id' => 'devise/registrations#update', 
        :as => 'registro_usuario'            
    end
    resources :usuarios, path_names: { new: 'nuevo', edit: 'edita' } 

    post 'usuarios/crea' => 'usuarios#create', :as => 'crea_usuario'           
    patch 'usuarios/:id/actualiza' => 'usuarios#update', 
      :as => 'actualiza_usuario'           
    get 'usuarios/reconfirma' => 'usuarios#reconfirma'
    post 'bitacora/admin' => 'sal7711_gen/bitacora#admin', 
      as: 'bitacora_publica'
    get 'bitacora/admin' => 'sal7711_gen/bitacora#admin', 
      as: 'bitacora_admin'
    get 'bitacora/tiempo' => 'sal7711_gen/bitacora#tiempo', 
      as: 'bitacora_tiempo'

    get 'lotes/nuevo' => 'lotes#new', as: 'new_lote'
    post  'lotes/nuevo' => 'lotes#create', as: 'create_lote'

    get 'lotes/ocrfaltante' => 'lotes#ocrfaltante', as: 'ocrfaltante'
    #  resource 'contacto', only: [:new, :create]

    resources 'lotes', only: [:new, :create, :index], 
      path_names: { new: 'nuevo', edit: 'edita' }

    root 'sal7711_gen/hogar#index'

#    namespace :admin do
#      ab = ::Ability.new
#      ab.tablasbasicas.each do |t|
#        #puts "OJO config/routes.rb, t=" + t.to_s
#        if (t[0] == "") 
#          c = t[1].pluralize
#          resources c.to_sym, 
#            path_names: { new: 'nueva', edit: 'edita' }
#        end
#      end
    end

  end

  mount Sal7711Gen::Engine, at: rutarel, as: 'sal7711_gen'
  mount Sip::Engine, at: rutarel, as: 'sip'

end
