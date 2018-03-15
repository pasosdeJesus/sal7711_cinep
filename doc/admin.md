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


## 4. Edición de información

### 4.1 Añadir un lote de artículos

Se hace desde Lotes->Añadir un lote

Un lote es un conjunto de artículos que posiblemente tienen características comunes de las registradas en el Archivo de Prensa.  Por ejemplo cuando proceden de la misma fuente de prensa o son de una misma fecha.

Para poder añadir el lote es necesario ubicar todas las imágenes de los artículos en una misma carpeta (que no tenga otras imágenes).   Es posible que un lote conste de un solo artículo pero aún así debe ser la única imagen en la carpeta del lote, y debe ser esa carpeta la que se elija en el campo "Artículos" del formulario para añadir un lote.

### 4.1.1 Formatos soportados

La visualización de los artículos típicamente se hace en el formato JPG y se posibilita la descarga de un PDF con la imagen (o con las imagenes en caso de que sean varias páginas). Estos formatos se generar automáticamente a partir de las imágenes que suba al sistema en otros formatos (como TIF, PNG, GIF y JPG).

Para escanear y subir información recomendamos que empleé el formato TIF por sus posibilidades multipágina.  Un artículo de una página debe escanearse en un TIF de una sóla página.  Un artículo de varias páginas (o varías partes) puede organizarse en un TIF de varias páginas, dejando cada parte del artículo en una página separada.   Así al emplear un TIF multipágina cuando se convierta a JPG las diversas páginas se concatenarán en una sóla imagen, pero al convertir a PDF, cada página del TIF se convertirá a una página diferente del PDF --que facilitará la lectura.


