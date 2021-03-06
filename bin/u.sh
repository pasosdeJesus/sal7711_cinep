#!/bin/sh
# Inicia produccion
if (test "${SECRET_KEY_BASE}" = "") then {
	echo "Definir variable de ambiente SECRET_KEY_BASE"
	exit 1;
} fi;
if (test "${USUARIO_AP}" = "") then {
	echo "Definir usuario con el que se ejecuta en USUARIO_AP"
	exit 1;
} fi;
if (test "$PGSSLCERT" = "") then {
	echo "Falta PGSSLCERT"
	exit 1;
} fi;
if (test "$PGSSLKEY" = "") then {
	echo "Falta PGSSLKEY"
	exit 1;
} fi;
DOAS=`which doas`
if (test "$DOAS" = "") then {
	DOAS=sudo
} fi;
$DOAS su - ${USUARIO_AP} -c "cd /var/www/htdocs/sal7711_cinep; PGSSLCERT=${PGSSLCERT} PGSSLKEY=${PGSSLKEY} RAILS_ENV=production bin/rails assets:precompile; echo \"Iniciando unicorn...\"; PGSSLCERT=${PGSSLCERT} PGSSLKEY=${PGSSLKEY} SECRET_KEY_BASE=${SECRET_KEY_BASE} bundle exec unicorn_rails -c ../sal7711_cinep/config/unicorn.conf.minimal.rb  -E production -D"

