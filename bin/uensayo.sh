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
DOAS=`which doas`
if (test "$DOAS" = "") then {
	DOAS=sudo
} fi;
$DOAS su ${USUARIO_AP} -c "cd /var/www/htdocs/sal7711_cinep-ensayo; RAILS_ENV=ensayo bundle exec rake assets:precompile; echo \"Iniciando unicorn...\"; SECRET_KEY_BASE=${SECRET_KEY_BASE} bundle exec unicorn_rails -c ../sal7711_cinep-ensayo/config/unicorn.conf.ensayo.rb -E ensayo -D"


  

