# Trucos y Atajos en el Archivo de Prensa CINEP

## 1. Búsqueda

### 1.1 Fecha

El cuadro emergente para elegir fecha permite buscar rápido presionando en el titulo.Por ejemplo si está viendo un mes y presiona el título verá los meses de ese año:
![Calendario 1](http://s6.postimg.org/uefdm148x/cal2.png)

Si vuelve a presionar verá 12 años:

![Calendario 2](http://s6.postimg.org/w8s83rr9d/cal3.png)


## 2. Funcionalidades adicionales a la búsqueda

### 2.1 Movil

### 2.2 API RESTful

https://archivoprensa.cinep.org.co/admin/categoriasprensa.json?term=politi


## 3. Administración

### 3.1 Planes
1 Plan individual. Creado por administrador del sistema, debe tener un tiempo de caducidad. En cada ingreso se bloquea acceso si sobrepasa el tiempo de caducidad. 

2 Plan corporativo con correo. Organización se inscribe, se identifica por el dominio del correo, tiene un tiempo de caducidad. Sus usuarios se suscriben, usando formulario cuando su correo usa el dominio de la organización. Deben confirmar correo para poder completar suscripción. Deben reconfirmar correo cada cierto tiempo. 

3 Plan corporativo con IP: organización se suscribe por un tiempo con una IP fija. Tendra un usuario anonimo. Los ingresos desde esa IP mientras estén dentro del tiempo de vigencia se autentican como el usuario anonimo.


### 3.2 Habilitación de un usuario en plan individual

Podrá operar siempre que:

- Tenga una fecha de renovación previa a la fecha actual
- Tenga unos días de vigencia tales que la fecha actual esté dentro de esos días contados a partir de la fecha de la última renovación.
- No tenga fecha de deshabilitación
- Intentos fallidos en un número inferior al límite, mejor en 0
- Testigo para desbloquear en blanco
- Hora de bloqueo en blanco
- Correo para confirmar en blanco
- Fecha de confirmación del correo anterior a la fecha actual

### 3.3 Habilitación de un usuario en plan corporativo con correo

Un usuario en un plan corporativo es similar al anterior excepto porque no requiere ni fecha de última renovación, ni días de vigencia pues se usan los de su organización.


## 4. Formatos soportados

La visualizacióne en web se hace con el formato JPG, pero se posibilita la descarga de un PDF con la imagen.

Se recomienda emplear TIF para las imágenes escanadas, las diversas páginas de un artículo en un TIF de una página.

Sin embargo si emplea un TIF multipágina, las diversas páginas se concatenarán en el JPG, pero se convertirán en un PDF multipágina.


