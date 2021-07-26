#!/bin/sh
# Inicia produccion

if (test "${DIRAP}" = "") then {
  echo "Definir directorio de aplicacion en DIRAP"
  exit 1;
} fi;

if (test -f "${DIRAP}/.env") then {
  . $DIRAP/.env
} fi;

if (test "${SECRET_KEY_BASE}" = "") then {
  echo "Definir variable de ambiente SECRET_KEY_BASE"
  exit 1;
} fi;
if (test "${USUARIO_AP}" = "") then {
  echo "Definir usuario con el que se ejecuta en USUARIO_AP"
  exit 1;
} fi;
#if (test "${RAILS_RELATIVE_URL_ROOT}" = "") then {
#  echo "Definir ruta relativa en URL en RAILS_RELATIVE_URL_ROOT"
#  exit 1;
#} fi;

if (test "${PGSSLCERT}" = "") then {
  PGSSLCERT=~/.postgresql/postgresql.crt
} fi;
if (test "${PGSSLKEY}" = "") then {
  PGSSLKEY=~/.postgresql/postgresql.key
} fi;

DOAS=`which doas 2>/dev/null`
if (test "$DOAS" = "") then {
  DOAS=sudo
} fi;

echo "RAILS_ENV=$RAILS_ENV"
defuroot=""
if (test "${RAILS_RELATIVE_URL_ROOT}" != "") then {
  defuroot="RAILS_RELATIVE_URL_ROOT=${RAILS_RELATIVE_URL_ROOT}"
} fi;

$DOAS su - ${USUARIO_AP} -c "cd $DIRAP; 
  echo \"== Iniciando unicorn... ==\"; 
  ${defuroot} PUERTOUNICORN=${PUERTOUNICORN} \
    CONFIG_HOSTS=${CONFIG_HOSTS}\
    DIRAP=$DIRAP \
    RAILS_ENV=${RAILS_ENV} \
    SECRET_KEY_BASE=${SECRET_KEY_BASE} \
    BD_SERVIDOR=${BD_SERVIDOR} \
    BD_CLAVE=${BD_CLAVE} \
    BD_USUARIO=${BD_USUARIO} \
    BD_ENSAYO=${BD_ENSAYO} \
    BD_PRO=${BD_PRO} \
    SMTP_MAQ=${SMTP_MAQ}  \
    SMTP_DOMINIO=${SMTP_DOMINIO} \
    SMTP_PUERTO=${SMTP_PUERTO} \
    SMTP_CLAVE=${SMTP_CLAVE} \
    SMTP_USUARIO=${SMTP_USUARIO} \
    PGSSLCERT=${PGSSLCERT} \
    PGSSLKEY=${PGSSLKEY} \
    RUTA_RELATIVA=${RUTA_RELATIVA} \
    HEB412_RUTA=${HEB412_RUTA} \
    bundle exec /usr/local/bin/unicorn_rails \
    -c $DIRAP/config/unicorn.conf.minimal.rb  -E $RAILS_ENV -D"

