# DOCKER

![width:480](img/docker-010.png)

<style>
emph {
  color: #E87B00;
}
</style>

## ¿Qué es Docker?

### Algunas definiciones:

1. Un entorno chroot (jaula de dependencias)
2. Contrato entre _sysadmin_  y  desarrollador
3. Empaquetador de aplicaciones
4. Un sistema de virtualización

## ¿Qué es Docker?

### 1. Un entorno _chroot_

Entorno aislado del sistema, donde se pueden instalar aplicaciones y librerías sin que afecte al sistema principal.

### 2. Contrato entre _sysadmin_  y desarrollador

El  administrador solo debe  __desplegar__  los contenedores, mientras que el  desarrollador puede trabajar e instalar con ellos sin poner en riesgo el sistema.

### 3. Empaquetador de aplicaciones

Se puede crear un  _container_ para la aplicación, de modo que se ejecuten igual en distintas máquinas.

## ¿Qué es Docker?

### 4. Un sistema de virtualización

__Virtual machine__: _Include the application, the necessary binaries and libraries, and an entire guest operating system –– all of which can amount to tens of GBs._

![Virtual machine](img/docker-011.png)

## Virtualización

__Container__: _Include the application and all of its dependencies –– but share the kernel with other containers, running as isolated processes in user space on the host operating system. Docker containers are not tied to any specific infrastructure: they run on any computer, on any infrastructure, and in any cloud._

![Container](img/docker-012.png)

## Virtualización de Docker

- Docker no solo virtualiza el hardware, también el sistema operativo.

- Docker es una tecnología de _código abierto_ para crear, ejecutar, probar e implementar aplicaciones distribuidas dentro de __contenedores__ de software

- Docker está basado en el sistema de virtualización de __Linux__ 

## Contenedores Docker

### ¿Qué es un contenedor?

- Los contenedores crean un __entorno virtual__ para las aplicaciones
- Ocupan  menos __espacio__  que una máquina virtual al no tener que almacenar el sistema completo.
- El tiempo de __arranque__ de un container  es inferior a 1 segundo.
- Para __integrar__ máquinas virtuales en un host, debemos establecer la red. En los contenedores de Docker la integración es directa. 

### Ventajas para desarrolladores

- __Dependencias__: Docker permite a los desarrolladores entregar servicios aislados, gracias a la eliminación de problemas de dependencias de ejecución del software.
- __Productividad__: Se  reduce el tiempo empleado en configurar los entornos o solucionar problemas relacionados con los mismos.
- __Despliegue__: Las aplicaciones compatibles con Docker se pueden desplegar desde equipos de desarrollo a versiones de producción.

## Instalación de Docker

- Trabajaremos con Ubuntu, aunque es posible en cualquier sistema operativo
- Docker solo trabaja con sistemas de 64 bits

### Instalación (Ubuntu)

Instrucciones de instalación:

https://docs.docker.com/engine/install/ubuntu/

Comprobar que se está ejecutando:

```bash
sudo docker --version
sudo service docker status
```

### Instalación (Windows)

- Docker está ya integrado en Windows 10, haciendo uso de Hyper-V
- Cuando se usa Docker no se puede utilizar __Virtual Box__, lo que puede significar un problema
- Tenemos la opción de deshabilitar Hyper-V. Para ello debemos ejecutar como administrador:

Apagar

```bash
bcdedit /set  hypervisorlaunchtype off
```

Encender

```bash
bcdedit /set hypervisorlaunchtype auto
```

## Usos sin necesidad de _sudo_ (opcional)

Para ejecutar el daemon de Docker y los contenedores sin ser superusuarios:

https://docs.docker.com/engine/security/rootless/

Creamos un grupo docker

`sudo groupadd docker`

Añadimos el usuario al grupo

`sudo usermod -aG docker $USER`

Cerramos sesión y volvemos a entrar

Comprobamos que se está ejecutando

`sudo service docker status`

## Comprobar la instalación

Vemos con qué versión estamos trabajando

`docker --version`

Lista de comandos

`docker`

Información del sistema

`docker info`

Descarga y ejecución de un contenedor básico

`docker run hello-world`

## Docker Hub

https://hub.docker.com/

Es un repositorio donde los usuarios de Docker pueden compartir las imágenes de los contenedores que han creado.

Existe una opción de pago para registro privado.

Tiene servicios automatizados [webhooks](https://docs.docker.com/docker-hub/webhooks/) y se puede integrar con Github y BitBucket.

Darse de alta como usuario

[https://hub.docker.com/](https://hub.docker.com/)

Iniciar sesión desde el terminal

`docker login`

Ver los repositorios locales descargados

`docker images`
> Tendremos el hello-world que hemos utilizado para comprobar que el servicio funcionaba

## Descargando de repositorios

Buscar un repositorio

`docker search ubuntu`

Descargar la versión oficial

`docker pull ubuntu`

> Podemos usar opciones como `ubuntu:14.04`, `ubuntu:latest`, etc.

Ejecutamos el contenedor

`docker run ubuntu /bin/echo "Pues parece que funciona"`

 > Al ejecutar `run`, si la imagen no existiera en el repositorio local, se descarga antes

## Repositorios en ejecución

Ver los contenedores en ejecución

`docker ps`

> `CONTAINER ID` es el identificador del contenedor
> `IMAGE` es la imagen usada para crearlo
> `NAME` -- si no se especifica, Docker crea un nombre aleatorio

Ver los contenedores que se han creado

`docker ps -a`

Ver el último repositorio creado

`docker ps -l`

Borrar una imagen

`docker rmi [nombre_imagen]`

## Trabajando en los contenedores

Poner nombre a un contenedor

`docker run -t -i --name myUbuntu ubuntu /bin/bash`

 `-t` incluye terminal dentro del contenedor
 `-i` se puede trabajar de manera interactiva

Para salir del terminal

`exit`

## Trabajando en los contenedores en ejecución

Poner nombre a un contenedor

```bash
docker run --name myUbuntu ubuntu /bin/bash \
    -c "while true; do echo hola mundo; sleep 1; done"
```

Vemos los contenedores que se están ejecutando

`docker ps`

Detenemos el contenedor

`docker stop [nombre contenedor]`

Borrar un contenedor

`docker rm [nombre_contenedor]`

## Trabajando en los contenedores ejecutando en segundo plano

Poner nombre a un contenedor

```bash
docker run -d --name myUbuntu ubuntu /bin/bash \
    -c "while true; do echo hola mundo; sleep 1; done"
```

 > __-d__ significa que se trabaje en segundo plano_ 

Vemos los contenedores que se están ejecutando: `docker ps`

Podemos ver la salida de nuestro contenedor: `docker logs myUbuntu`

Detenemos el contenedor

`docker stop [nombre contendedor]`

Abrir terminal de un determinado contenedor

`docker exec -it myUbuntu /bin/bash`

## Trabajando con Docker

![w:640](img/docker-013.png)

## Opciones

Exportar un contenedor

`docker export myUbuntu > myUbuntu.tar`

Importar desde un fichero local

`docker import /path/to/latest.tar`

## Ejemplo: contenedor con aplicación web en Python

Descargamos la imagen

`docker run -d -P training/webapp python app.py`

> __-d__ trabajar en segundo plano
> __-P__ mapea los puertos a nuestro host para poder ver la aplicación

Ejecuta con `python` la aplicación web de servidor `app.py`, contenida en la imagen `training/webapp`

Vemos los puertos usados: `docker ps -a`

> La opción **-P** redirecciona los puertos del contenedor de la imagen (en este caso el 5000) a un puerto de nuestro host local: `[0.0.0.0:55000->5000/tcp]`

Abrir en el navegador http://localhost:55000/

### Otras opciones de ejecución

Especificando un puerto en el host

`docker run --name myWeb -d -p 80:5000 training/webapp python app.py`

> **-p** mapea el puerto 80 del host local al 5000 del contenedor

Abrir en el navegador http://localhost

Podemos ver los puertos asociados a nuestro contenedor

`docker port [nombre contenedor] puerto`

`docker port myWeb 5000`

Podemos ver los logs de nuestra aplicación

`docker logs -f myWeb`
> **-f** muestra los logs de manera continua

Ver procesos que se están ejecutando en el contenedor 

`docker top myWeb`

Inspeccionar la máquina

`docker inspect myWeb`

Detener el contenedor

`docker stop myWeb`

Reiniciar un contenedor

`docker start myWeb`


## Creando nuestros contenedores

- Creación __desde imagen__: Partimos de una imagen de un contenedor para realizar modificaciones y crear el nuestro

- Creación desde cero: Partimos de un __fichero de configuración__ para crear una imagen para un contenedor

### Creación desde una imagen

Ejecutar el contenedor `myWeb`

`docker run --name myWeb -t -i  -d -p 80:5000 training/webapp python app.py`

Abrir un terminal del contenedor

`docker exec -t -i myWeb /bin/bash`


Instalar nano, editar `app.py` y hacer commit

```bash
docker commit -m "Modificando saludo" -a "Mi Nombre" ac1c3a5c70ad \
    usuario/myweb:v2
```

> - Especificar el id del contenedor en ejecución a modificar
> - `usuario`  debe coincidir con nuestro usuario de Docker Hub
> - El nombre de la imagen `myweb` debe ir en minúsculas

Vemos nuestra nueva imagen

`docker images`

Ejecutar nuestra imagen

```
docker run --name myWeb2 -t -i  -d -p 80:5000 \
    usuario/myweb:v2 python app.py
```


### Creación de un _Dockerfile_

https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/


## Comandos básicos de Dockerfile

__FROM:__   para definir la imagen base
__MAINTAINER:__    nombre o correo del mantenedor
__COPY:__   copiar un fichero o directorio a la imagen
__ADD:__   para copiar ficheros desde urls
__RUN:__   ejecutar un comando dentro del container
__CMD:__   comando por defecto cuando ejecutamos un container
__ENV:__   variables de entorno
__EXPOSE:__   para definir los puertos del contenedor
__VOLUME:__   para definir directorios de datos que quedan fuera de la imagen
__ENTRYPOINT:__   comando a ejecutar de forma obligatoria al correr una imagen
__USER:__   Usuario para RUN, CMD y ENTRYPOINT
__WORKDIR:__   directorio para ejecutar los comandos


## Ejemplo de Dockerfile

Creamos un directorio: `mkdir myapacheweb && cd myapacheweb`

Creamos un fichero llamado Dockerfile: `touch Dockerfile`

Editamos el fichero con el siguiente contenido:

```docker
FROM ubuntu:14.04 
RUN apt-get update && \
  apt-get install -y apache2 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* 
RUN echo "<h1>Apache with Docker</h1>" > /var/www/html/index.html 
ENV APACHE_RUN_USER www-data 
ENV APACHE_RUN_GROUP www-data 
ENV APACHE_LOG_DIR /var/log/apache2 
EXPOSE 80 
ENTRYPOINT apache2ctl -D FOREGROUND 
```


Construcción de nuestra imagen

`docker build -t usuario/myserver .`

Ejecutamos nuestra imagen

`docker run -i -t -p 3333:80 --name myserver usuario/myserver:latest`

Probar el contenedor y abrir http://localhost:3333/

Colocamos nuestra imagen en Docker Hub

`docker push usuario/myserver`

Averiguar el tamaño de las imágenes

`docker history usuario/myserver`


### Imagen de Ubuntu

La imagen de ubuntu no trae muchas de las herramientas necesarias para comprobar el funcionamiento del contenedor. Se recomienda instalar las siguientes herramientas.

```bash
apt-get update
apt-get install nano
apt-get install -y net-tools
apt-get install telnet
apt-get install iputils-ping
apt-get install curl
```


<style scoped>
p {
  text-align: center;
  font-size: 125%;
  color: green;
}
</style>

## Tutorial de Docker

[https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)

# Ejercicio: Apache server

Tareas:

1. Crear un contenedor con Apache Server 2 (buscar en Docker Hub)
2. Personalizar el contenedor. El servidor por defecto muestra en la página principal "It works!". Modificar este mensaje para que muestre un saludo personal: "Hello + (tu nombre y apellidos)!".
3. Configurarlo para que por defecto utilice el puerto 8082.
4. Subir la imagen del contenedor creado a Docker Hub. La imagen debe llamarse `apacheserver_p1`.


Construir una imagen nueva

```bash
mkdir mi-apache
nano index.html
mv index.html mi-apache
nano Dockerfile
```

Dockerfile:
```docker
FROM bitnami/apache
COPY index.html /opt/bitnami/apache/htdocs/index.html
```

```bash
docker build -t usuario/mi-apache .
docker run -d -P --name=mi-apache-1 usuario/mi-apache
```

Subir nueva imagen a Docker Hub:

`docker push usuario/mi-apache`


## Directorios enlazados y volúmenes

Para compartir información con Docker cuando necesitamos:

- Compartir un __directorio__ entre múltiple contenedores.
- Compartir __un directorio__ entre el host y un contenedor.
- Compartir __un fichero__ entre el host y un contenedor.

Opciones:

- __Directorios enlazados__ *(bind):* la información se guarda fuera de Docker en el host local. Esta opción es mejor para datos no generados por los contenedores.
- __Volúmenes__: la información se guarda usando Docker. Mejor para datos generados por los propios contenedores.


## Directorios enlazados (bind)

Características:

- Permiten  __persistencia__  de la información del contenedor.
- Se montan en un  __path específico de la máquina local__  (fuera de Docker).
- Permiten  __borrar los contenedores sin perder la información__ .


### Ejemplo con directorios enlazados (bind) (1)

Crear directorio local `p02` para compartir:

`mkdir /Users/Usuario/p02`

Ejecutar el contenedor:

```bash
docker run -d -P --name=apache-bind-1 \
  --mount type=bind,source=`pwd`/p02,target=/app bitnami/apache
```

Comprobar los puertos a los que se ha asignado el 8080 (http) y 8443 (https) del Servidor Apache configurado en el contenedor:

```bash
$ docker ps -a
CONTAINER ID   IMAGE           COMMAND                 CREATED        STATUS         PORTS                                              NAMES
...
bcaae8157e45   bitnami/apache  "/opt/bitnami/script…"  3 minutes ago  Up 3 minutes   0.0.0.0:55004->8080/tcp, 0.0.0.0:55003->8443/tcp   apache-bind-1
...
```


Editar el fichero con _nano_ (u otro editor)

`nano /Users/Usuario/p02/index.html`

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Apache en Docker</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
  <h1>Hola Usuario! :)</h1>
</body>
</html>
```



Abrir en el host las URL http://localhost:55004/ y https://localhost:55003/
(para ver los cambios podría ser necesario reiniciar Apache, aunque también podemos reiniciar el contenedor con `docker restart apache-bind-1`)

![width:550](img/iiss-docker-021.png) ![width:550](img/iiss-docker-022.png)

Si eliminamos el contenedor, no perdemos el contenido de la web:


```bash
docker stop apache-bind-1
docker rm apache-bind-1
docker run -d -P --name=apache-bind-2 \
  --mount type=bind,source=`pwd`/p02,target=/app bitnami/apache
```


## Volúmenes

### Características

- Permiten persistencia de información del contenedor
- Se montan en un _path_ específico del contenedor
- El acceso a la información sólo puede realizarse a través de Docker


### Ejemplo con volúmenes (1)

Creando un volumen para la web

```
docker run -d -P --name=apache-volume-1 \
   --mount type=volume,source=vol-apache,target=/app bitnami/apache
```

Comprobar el puerto asignado con `docker ps -a `


Acceso al volumen

`docker volume ls`

`docker exec -it apache-volume-1 /bin/bash`

Comprobar que `/app` está vacía y salir con `exit`

Actualizamos el contenido del volumen

`nano index.html`

`docker cp index.html apache-volume-1:app/`

Acceso de nuevo al volumen y comprobar que está el archivo `index.html`

`docker exec -it apache-volume-1 /bin/bash`



Acceso al contenido de la web

![width:550](img/iiss-docker-023.png)

Compartir volumen con otro contenedor

```
docker run -d -P --name=apache-volume-2 \
   --mount type=volume,source=vol-apache,target=/app bitnami/apache
```


Borrando volumen

```
docker stop apache-volume-2
docker rm apache-volume-2
```

`docker volume rm vol-apache`

```
Error response from daemon: remove vol-apache: volume is in use - [4a4794f86...3c8]
```

Reintentar borrado:

```
docker stop apache-volume-1
docker rm apache-volume-1
docker rm apache-volume-2
docker volume rm vol-apache
```

Comprobar que se ha borrado con `docker volume ls`


##  Configuraciones de red

- Permiten comunicación entre todos los contenedores pertenecientes a una red a través del nombre del contenedor
- Permiten aislamiento con respecto a otros contenedores
- Un contenedor puede pertenecer a varias redes


###  Tipos de redes

Ver las redes existentes: `docker network ls`

```bash
$ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
21c353b4b7a5   bridge    bridge    local
7a7abec15748   host      host      local
40157ecf9fcf   none      null      local
```

- **host** representa la red del propio equipo y haría referencia a `eth0`
- **bridge** representa la red `docker0` y a ella se conectan todos los contenedores por defecto 
- **none** significa que el contenedor no se incluye en ninguna red. Si verificamos esto con el comando `ifconfig` dentro del contenedor, veríamos que sólo tiene la interfaz de loopback `lo`

Saber qué contenedores usan un tipo de red: `docker network inspect bridge`


###  Ejemplo de configuración de red (1)

WordPress empaquetado en un contenedor:

https://github.com/bitnami/charts/tree/main/bitnami/wordpress

Crear una nueva red:

`docker network create wordpress-network`

Crear primer volumen para persistencia de MariaDB:

`docker volume create --name mariadb_data`

Crear segundo volumen para persistencia de WordPress:

`docker volume create --name wordpress_data`


Crear primer contenedor que usa la red (base de datos `mariadb`):

```bash
docker run -d --name mariadb --env ALLOW_EMPTY_PASSWORD=yes \
  --env MARIADB_USER=bn_wordpress \
  --env MARIADB_DATABASE=bitnami_wordpress \
  --network wordpress-network \
  --volume mariadb_data:/bitnami/mariadb \
  bitnami/mariadb:latest
```

Crear segundo contenedor que usa la red (servidor `wordpress`):

```bash
docker run -d --name wordpress -p 8080:8080 -p 8443:8443 \
  --env ALLOW_EMPTY_PASSWORD=yes \
  --env WORDPRESS_DATABASE_USER=bn_wordpress \
  --env WORDPRESS_DATABASE_NAME=bitnami_wordpress \
  --network wordpress-network \
  --volume wordpress_data:/bitnami/wordpress \
  bitnami/wordpress:latest
```


![width:600 center](img/wordpress.png)


# Ejercicio: Nginx con red y volumen compartido

Realizar los siguientes ejercicios para trabajar los conceptos vistos durante la práctica.


## Parte 1

1. Crear volumen compartido `volumenDocker`
2. Crear un contenedor de Nginx que use el volumen `volumenDocker`.
3. Modifique el contenido del fichero `index.html` incluyendo un saludo personal en lugar del texto por defecto.
4. Cree un segundo contenedor que también use el volumen `volumenDocker`.
5. Compruebe que puede acceder a `localhost:80` (primer contenedor) y `localhost:81` (segundo contenedor) y ver el contenido de `index.html`.


## Parte 2

1. Crear una nueva red `redDocker`.
2. Crear un contenedor de Ubuntu `Ubuntu1`.
3. Crear un contenedor de Ubuntu `Ubuntu2`.
4. Conectar `Ubuntu1` a la red `redDocker`.
5. Intentar hacer ping a `Ubuntu1` desde `Ubuntu2`. ¿Funciona? ¿Por qué?.
6. Conectar `Ubuntu2` a la red `redDocker`.
7. Intentar de nuevo hacer ping a `Ubuntu1` desde `Ubuntu2`. ¿Funciona? ¿Por qué?.