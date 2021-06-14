# encoding: UTF-8

include Devise::Controllers::SignInOut

class Ability  < Sal7711Gen::Ability

  ROLADMIN      = 1
  ROLADMINORG   = 2
  ROLINDEXADOR  = 3
  ROLINV        = 4
  ROLINVANON    = 5

  ROLES = [
    ["Administrador", ROLADMIN],  # 1
    ["Administrador Organización", ROLADMINORG], # 2
    ["Indexador", ROLINDEXADOR], # 3
    ["Investigador", ROLINV], # 4
    ["Investigador Anónimo", ROLINVANON], # 5
  ]

  ROLES_CA = [
    'Administrar artículos. ' +
    'Administrar lotes. ' +
    'Administrar tablas básicas (categorias de prensa, etc). ' +
    'Consultar bitácora. ' +
    'Administrar usuarios. ' +
    'Cambiar su clave. ', #ROLADMIN 1

    'Administrar artículos. ' +
    'Consultar categorias de prensa. ' +
    'Administrar lotes. ' +
    'Cambiar su clave. ', #ROLADMINORG 2

    'Administrar artículos. ' +
    'Consultar categorias de prensa. ' +
    'Administrar lotes. ' +
    'Administrar ubicaciones. ' +
    'Cambiar su clave. ', #ROLINDEXADOR 3

    'Consultar artículos. ' +
    'Consultar categorias de prensa. ' +
    'Consultar ubicaciones. ' +
    'Cambiar su clave. ', #ROLINV 4

    'Consultar artículos. ' +
    'Consultar categorias de prensa. ' +
    'Consultar ubicaciones. ' #ROLINVANON 5

  ]


  BASICAS_PROPIAS =  [
    ['', 'organizacion']
  ]

  NOBASICAS_INDSEQID = [
    ['', 'lote'],
    ['sal7711_gen', 'bitacora']
  ]


  def tablasbasicas 
    Sip::Ability::BASICAS_PROPIAS + 
      Sal7711Gen::Ability::BASICAS_PROPIAS + 
      BASICAS_PROPIAS  - [
        ['Sip', 'clase'],
        ['Sip', 'etiqueta'],
        ['Sip', 'grupo'],
        ['Sip', 'oficina'],
        ['Sip', 'perfilorgsocial'],
        ['Sip', 'sectororgsocial'],
        ['Sip', 'tclase'],
        ['Sip', 'tdocumento'],
        ['Sip', 'trelacion'],
        ['Sip', 'tsitio']
      ] 
  end

  def basicas_id_noauto 
    Sip::Ability::BASICAS_ID_NOAUTO +
      Sal7711Gen::Ability::BASICAS_ID_NOAUTO 
  end

  def nobasicas_indice_seq_con_id
    Sip::Ability::NOBASICAS_INDSEQID +
      Sal7711Gen::Ability::NOBASICAS_INDSEQID +
      NOBASICAS_INDSEQID 
  end

  def tablasbasicas_prio 
    Sip::Ability::BASICAS_PRIO +
      Sal7711Gen::Ability::BASICAS_PRIO 
  end
  
  @@ultimo_error_aut = "";

  def self.ultimo_error_aut
    @@ultimo_error_aut
  end

  def self.ultimo_error_aut=(v)
    @@ultimo_error_aut = v
  end

  # Autorizacion con CAnCanCan
  def initialize(usuario = nil)
    # El primer argumento para can es la acción a la que se da permiso, 
    # el segundo es el recurso sobre el que puede realizar la acción, 
    # el tercero opcional es un diccionario de condiciones para filtrar 
    # más (e.g :publicado => true).
    #
    # El primer argumento puede ser :manage para indicar toda acción, 
    # o grupos de acciones como :read (incluye :show e :index), 
    # :create, :update y :destroy.
    #
    # Si como segundo argumento usa :all se aplica a todo recurso, 
    # o puede ser una clase.
    # 
    # Detalles en el wiki de cancan: 
    #   https://github.com/ryanb/cancan/wiki/Defining-Abilities
    if !usuario
        return
    end
    return if usuario.fechadeshabilitacion
    can :contar, Sip::Ubicacion
    can :buscar, Sip::Ubicacion
    can :lista, Sip::Ubicacion
    can :index, Sip::Pais
    can :read, Sip::Departamento
    can :index, Sip::Departamento
    can :read, Sip::Municipio
    can :index, Sip::Municipio
    can :index, Sip::Clase
    can :descarga_anexo, Sip::Anexo
    can :nuevo, Sip::Ubicacion
    if usuario.rol then
      diasv = usuario.diasvigencia
      fechar = usuario.fecharenovacion
      pdom = usuario.email.split("@")
      if pdom.count == 2 
        dom = pdom[1]
        org = ::Organizacion.where(dominiocorreo: dom).take
        if org # plan corporativo correo
          diasv = org.diasvigencia
          fechar = org.fecharenovacion
        end
      end

      can :read, Sal7711Gen::Articulo
      can :read, Sal7711Gen::Categoriaprensa
      can :read, Sip::Ubicacion
      can :new, Sip::Ubicacion
      can [:update, :create, :destroy], Sip::Ubicacion
      revisarvig = true
      case usuario.rol 
      when Ability::ROLINVANON
      when Ability::ROLINV
        can :cambiarclave, ::Usuario
      when Ability::ROLADMINORG
        can :cambiarclave, ::Usuario
      when Ability::ROLINDEXADOR
        revisarvig = false
        can :cambiarclave, ::Usuario
        can :manage, Sip::Ubicacion
        can :manage, Sal7711Gen::Articulo
        can :manage, Lote
      when Ability::ROLADMIN
        revisarvig = false
        can :cambiarclave, ::Usuario
        can :manage, Sal7711Gen::Bitacora
        can :manage, Sal7711Gen::Categoriaprensa
        can :manage, Sal7711Gen::Articulo
        can :manage, Sip::Ubicacion
        can :manage, Usuario
        can :manage, Lote
        can :manage, :tablasbasicas
        tablasbasicas.each do |t|
          c = Ability.tb_clase(t)
          can :manage, c
        end
      end

      if revisarvig
        if !diasv  || !fechar
          @@ultimo_error_aut = 
            "Usuario sin fecha de renovación o tiempo de vigencia"
          return
        end
        fechaf = fechar + diasv
        hoy = Date.today
        if hoy < fechar || hoy > fechaf
          @@ultimo_error_aut = "Sin vigencia"
          return
        end
      end # revisarvig

    end
  end

end

