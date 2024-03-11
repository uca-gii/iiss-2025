---
marp: true
title: Prácticas de Terraform para Infraestructura Docker
description: Asignaturas del grado en Ingeniería Informática 
---

<!-- size: 16:9 -->
<!-- theme: default -->

<!-- paginate: skip -->
<!-- headingDivider: 1 -->

<style>
h1 {
  text-align: center;
  color: #005877;
}
h2 {
  color: #E87B00;
}
h3 {
  color: #005877;
}

img[alt~="center"] {
  display: block;
  margin: 0 auto;
}
img[alt~="float"] {
  display: float;
  margin: 8px 5px 0 5px;
}
emph {
  color: #E87B00;
}
</style>

# Terraform para Infraestructura Docker

![width:640 center](img/Terraform_PrimaryLogo_Color_RGB.svg)

---

<!-- paginate: true -->

## Introducción a Terraform (I)

Terraform es una herramienta de código abierto que permite automatizar la implementación y gestión de infraestructura como código (IaC).

IaC es una metodología que permite definir y administrar la infraestructura de una aplicación utilizando archivos de configuración en lugar de configuraciones manuales.

- Automatización: automatiza la creación, configuración y gestión de recursos de infraestructura, lo que ahorra tiempo y reduce errores

- Declarativo: se decribe el estado de la infraestructura en lugar de escribir scripts

- Multiplataforma: compatible con una variedad de proveedores de nube y tecnologías: AWS, Azure, Google Cloud, Kubernetes, Docker...

- Colaboración y Replicabilidad: archivos de configuración legibles y versionables

---

## Introducción a Terraform (II)

![width:720 center](img/terraform_architecture.avif)

- Creación de los archivos Terraform (IaC)
- Plan: Vista previa de los cambios que Terraform realizará para que coincidan con tu configuración
- Apply: Se aplican los cambios planificados

---

## Introducción a Terraform (III)

### Uso de Terraform para Infraestructura Docker

Terraform permite crear y gestionar una infraestructura Docker completa: contenedores, imágenes, redes y volúmenes.

En esta práctica, se utilizará Terraform para crear y gestionar una infraestructura Docker.

![width:400 center](img/docker-010.png)

---

## Instalación de Terraform (I)

https://developer.hashicorp.com/terraform/downloads

### Instalación (Linux)

```bash
sudo apt update
sudo apt install terraform
```

### Instalación (MacOS)

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

---

## Instalación de Terraform (II)

https://developer.hashicorp.com/terraform/downloads

### Instalación (Windows)

Instalación con [chocolatey](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

```shell
choco install terraform
```

---

## Creación de Infraestructura Docker con Terraform (I)

Primero, crea un directorio de trabajo para tus prácticas de Terraform.

```bash
mkdir mi_proyecto_terraform
cd mi_proyecto_terraform
```

Dentro del directorio de trabajo, inicializa un proyecto Terraform con el siguiente comando:

```bash
terraform init
```

---

## Creación de Infraestructura Docker con Terraform (II)

El comando `terraform init` se utiliza para inicializar un directorio de trabajo de Terraform. Cuando ejecutas este comando, Terraform realiza varias tareas importantes:

- Descarga de <emph>proveedores</emph>: Terraform identifica y descarga los proveedores de recursos específicos que se utilizarán en tu configuración. Por ejemplo, si estás creando una infraestructura Docker, Terraform descargará el proveedor de Docker.

- Inicialización del <emph>estado</emph>: El estado es un archivo que almacena información sobre la infraestructura gestionada.

- Validación de la <emph>configuración</emph>: Terraform verifica la sintaxis y la validez de tus archivos de configuración.

---

## Creación de Infraestructura Docker con Terraform (III)

### Estado de Terraform

El estado de Terraform almacena información sobre la infraestructura que estás gestionando, incluidos los recursos que Terraform ha creado y su estado actual.

- Permite comprender la diferencia entre la infraestructura deseada y la existente
- Se almacena de forma segura y puede ser compartido entre miembros del equipo
- Puede contener información sensible, como contraseñas o claves secretas

A continuación se muestra un ejemplo de estado de Terraform:
- Información sobre el recurso `docker_container` llamado `my_container`
- Incluye la imagen utilizada
- Incluye los puertos mapeados

---

### Ejemplo de Estado de Terraform

```plaintext
# terraform.tfstate
{
  "version": 4,
  "terraform_version": "1.0.5",
  "serial": 1,
  "lineage": "4d4a0f63-80d7-4b48-9a92-09c4909d5e6b",
  "outputs": {},
  "resources": [
    {
      "module": "",
      "mode": "managed",
      "type": "docker_container",
      "name": "my_container",
      "provider": "provider[docker]",
      "instances": [
        {
          "schema_version": 2,
          "attributes": {
            "command": null,
            "image": "nginx:latest",
            "name": "mi-contenedor",
            "networking_type": "bridge,container:mi-contenedor",
            "ports": [
              {
                "external": 8080,
                "internal": 80,
                "ip": "0.0.0.0",
                "type": "tcp"
              }
            ],
            "volumes": []
          },
          "private": "hidden sensitive data"
        }
      ]
    }
  ]
}
```

---

## Creación de archivos de configuración (I)

---

### Ejemplo de configuración `nginx.tf`

```ruby
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}
# Para Windows, añadir:  host = "npipe:////.//pipe//docker_engine"

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "practica_terraform"
  ports {
    internal = 80
    external = 8000
  }
}
```

---

## Creación de archivos de configuración (II)

```ruby
terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
```

- El bloque `terraform` define la configuración de Terraform. En este caso, hemos especificado el proveedor de Docker que se utilizará y su versión (igual o superior a 3.0.1 pero inferior a 4.0.0).
- Terraform instala los proveedores del Registro de Terraform ([Terraform Registry](https://registry.terraform.io/)) de forma predeterminada

---

## Creación de archivos de configuración (III)

```ruby
provider "docker" {}
# Para Windows, añadir:  host = "npipe:////.//pipe//docker_engine"
```

- El bloque `provider` especifica la configuración del proveedor Docker. En este caso, no se especifica ninguna configuración adicional

---

## Creación de archivos de configuración (IV)

```ruby
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}
```

- El bloque `resource` crea una imagen Docker a partir de otra imagen indicada (en este caso _nginx_). La imagen se descargará automáticamente si no existe localmente
- El prefijo del tipo se relaciona con el nombre del proveedor. Terraform gestiona el recurso `docker_image` con el proveedor docker. 
- El tipo y el nombre del recurso forman un ID único para el recurso (`docker_image.nginx`).

---

## Creación de archivos de configuración (V)

```ruby
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "practicas"
  ports {
    internal = 80
    external = 8000
  }
}
```

- Los bloques de recursos contienen argumentos para configurar los recursos. El bloque `docker_container` crea un contenedor Docker utilizando la imagen anterior
- Además, realiza un mapeo de puertos para exponer el puerto `80` interno como el puerto `8000` externamente

Ejecutar `terraform init` para inicializar el directorio de trabajo con la nueva configuración.

---

## Formateo y validación

Es recomendable utilizar un formato consistente en los archivos de configuración.

El comando `terraform fmt` actualiza automáticamente las configuraciones en el directorio actual para mejorar la legibilidad y la consistencia.

```bash
terraform fmt
```

Terraform imprimirá los nombres de los archivos que modificó. Si no se modificó ningún archivo, no se imprimirá nada.

Puede comprobarse si la configuración es sintácticamente válida utilizando el comando:

```bash
terraform validate
```

---

## Planificación de la creación de la infraestructura

Antes de aplicar cambios, es una buena práctica realizar una planificación para comprender qué recursos se crearán o modificarán y cómo afectarán a la infraestructura.

La planificación da una vista previa de los cambios que Terraform realizará.

Para planificar la creación de la infraestructura, utiliza el siguiente comando:

```bash
terraform plan
```

Terraform escaneará tus archivos de configuración, evaluará la infraestructura actual y generará un plan detallado de los cambios propuestos.

---

## Creación de la infraestructura (I)

Para crear la infraestructura, aplica los archivos de configuración del directorio actual mediante:

```bash
terraform apply
```

- Terraform escaneará tus archivos de configuración, evaluará la infraestructura actual, generará un plan detallado de los cambios propuestos y lo aplicará.
- Esto incluirá la creación de nuevos recursos, actualizaciones de recursos existentes y la destrucción de recursos obsoletos si los hay.

La información mostrada es similar a la de `terraform plan`.

---

## Creación de la infraestructura (II)

```plaintext
  # docker_image.nginx will be created
  + resource "docker_image" "nginx" {
      + id           = (known after apply)
      + keep_locally = false
      + latest       = (known after apply)
      + name         = "nginx:latest"
      + output       = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

- La salida con `+` indica que se creará este recurso
- Debajo, se muestran los atributos que se definirán para el recurso

Terraform solicitará confirmación antes de aplicar los cambios (`yes` para continuar).

---

## Creación de la infraestructura (III)

Una vez creada la infraestructura, Terraform mostrará un resumen de los recursos creados.

Podemos comprobar los contenedores creados con `docker ps` y acceder a la aplicación en http://localhost:8000.

El archivo de estado de Terraform (`terrafor.tfstate`) se habrá creado/actualizado con la información de los recursos creados.

Estado actual de la infraestructura:
```bash
terraform show
```

Listar los recursos actuales:
  
```bash
terraform state list
```

---

## Modificación de la infraestructura

Modifica el archivo de configuración para cambiar el puerto externo a 8001:

```ruby
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "practicas"
  ports {
    internal = 80
    external = 8001
  }
}
```

Aplica los cambios con `terraform apply` y comprueba que el contenedor se ha recreado con el nuevo puerto http://localhost:8001.

- El prefijo `-`/`+` significa que Terraform destruirá y volverá a crear el recurso
- Terraform puede actualizar algunos atributos (prefijo `~`), pero cambiar el puerto de un contenedor requiere recrearlo

---

## Destrucción de la infraestructura

Cuando ya no necesites ciertos recursos o quieras eliminar completamente la infraestructura, puedes utilizar el siguiente comando para destruirla:

```bash
terraform destroy
```

Se mostrará un plan de destrucción similar al de `terraform plan` y se solicitará confirmación antes de aplicar los cambios.

Tras confirmar, se eliminarán los recursos de la infraestructura.

En el caso de Docker, los contenedores se eliminarán y las imágenes se eliminarán si no se utilizan en otros contenedores.

---

## Aplicación de Variables de Entorno (I)

Las variables de Terraform permiten escribir configuraciones dinámicas y flexibles.

Las variables se pueden definir con un bloque `variable` en el mismo archivo de configuración (`nginx.tf`) o en un archivo separado `variables.tf`:

```ruby
variable "container_name" {
  description = "Value of the name for the Docker container"
  type        = string
  default     = "NginxContainer"
}
```

- El nombre de la variable es `container_name`
- La descripción es opcional, pero es una buena práctica incluirla
- El tipo de variable es `string`
- El valor predeterminado es `NginxContainer`

---

## Aplicación de Variables de Entorno (II)

Para utilizar la variable en el archivo de configuración, se utiliza la sintaxis `${var.container_name}`:

```ruby
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "${var.container_name}"
  ports {
    internal = 80
    external = 8001
  }
}
```

Aplica los cambios con `terraform apply` y comprueba que el contenedor se ha recreado con el nuevo nombre.

---

## Aplicación de Variables de Entorno (III)

Si lo que queremos es añadir variables de entorno al contenedor Docker, podemos utilizar el atributo `env`:

```ruby
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "${var.container_name}"
  ports {
    internal = 80
    external = 8001
  }
  env = [
    "MY_ENV_VAR=my_env_value"
  ]
}
```

---

## Volúmenes de Docker

Para añadir un volumen de Docker, usa el recurso docker_volume en la configuración:
  
```ruby
resource "docker_volume" "my_volume" {
  name = "my_volume"
}
```

Para utilizar el volumen en un contenedor, se utiliza el bloque `volumes`:

```ruby
resource "docker_container" "nginx" {
  ...
  volumes {
    volume_name = docker_volume.my_volume.name
    container_path = "/usr/share/nginx/html"
  }
}
```

Cada volumen se define indicando el nombre del volumen y la ruta de montaje dentro del contenedor.

---

## Redes de Docker

Para añadir una red de Docker, usa el recurso docker_network en la configuración:
  
```ruby
resource "docker_network" "my_network" {
  name = "my_network"
}
```

Para utilizar la red en un contenedor, se utiliza el bloque `networks_advanced`:

```ruby
resource "docker_container" "nginx" {
  ...
  networks_advanced {
    name = docker_network.my_network.name
  }
}
```

---

## Tarea Entregable

1. Crea una infraestructura Docker personalizada utilizando Terraform.
2. La infraestructura debe contener un contenedor con una aplicación Wordpress y otro contenedor con una base de datos MariaDB.
3. Deben estar conectados a una red Docker.
4. Debe existir un volumen para almacenar los datos de la base de datos y que no se eliminen al destruir la infraestructura.
5. Deben usarse variables de entorno para configurar la aplicación Wordpress.
6. Debe existir un archivo de configuración `variables.tf` con las variables de entorno.

