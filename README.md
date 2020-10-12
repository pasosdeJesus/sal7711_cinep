# Sal7711

[![Revisado por Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com) [![Estado Construcción](https://api.travis-ci.org/pasosdeJesus/sal7711_cinep.svg?branch=master)](https://travis-ci.org/pasosdeJesus/sal7711_cinep) [![Clima del Código](https://codeclimate.com/github/pasosdeJesus/sal7711_cinep/badges/gpa.svg)](https://codeclimate.com/github/pasosdeJesus/sal7711_cinep) [![Cobertura de Pruebas](https://codeclimate.com/github/pasosdeJesus/sal7711_cinep/badges/coverage.svg)](https://codeclimate.com/github/pasosdeJesus/sal7711_cinep) [![security](https://hakiri.io/github/pasosdeJesus/sal7711_cinep/master.svg)](https://hakiri.io/github/pasosdeJesus/sal7711_cinep/master)

![Logo de sal7711_cinep](https://raw.githubusercontent.com/pasosdeJesus/sal7711_cinep/master/app/assets/images/logo.png)

Archivo de Prensa del CINEP/PPP

### Requerimientos

Ver <https://github.com/pasosdeJesus/sip/wiki/Requerimientos>

Para hacer reconocimiento de caracteres se requiere ```tessearact``` y
su  módulo de español.  En adJ (OpenBSD) los instala con:

```
doas pkg_add tesseract
doas pkg_add tesseract-spa 
```

### Arquitectura

Es una aplicación que emplea los motores genéricos 
[sal7711_gen](https://github.com/pasosdeJesus/sal7711_gen)
y  [sip](https://github.com/pasosdeJesus/sip)


## Uso

Por favor vea las instrucciones de sivel2 pues son análogas:
<https://github.com/pasosdeJesus/sivel2>

Para iniciar requiere definida la varible de entorno

SAL7711_ONBASE_SERV=http://191.153.174.105:2400

Se usa para armar el URL de los correos de confirmación 
(usado por ejemplo al cambiar correo de un usuario).

Para hacer OCR emplea tesseract, asi:

	tesseract imagen stdout   -l spa
