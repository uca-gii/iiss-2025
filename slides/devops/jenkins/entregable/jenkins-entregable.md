---
marp: true
title: Entregable Jenkins
description: Asignaturas del grado en Ingeniería Informática 
---

<!-- size: 16:9 -->
<!-- theme: default -->

<!-- paginate: false -->
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

# Práctica de Jenkins - Entregable

---

## Descripción del ejercicio (I)

Debéis realizar un despliegue de una aplicación Python mediante un pipeline de Jenkins tal como se indica en el siguiente tutorial:

https://www.jenkins.io/doc/tutorials/build-a-python-app-with-pyinstaller/

- La base del tutorial es la misma que la vista en clase para la aplicación de React. La diferencia es que en este caso se trata de una aplicación Python
- Usaremos Jenkins desplegado en un contenedor Docker
- Debéis crear un fork del repositorio indicado en el tutorial
- En el tutorial emplea un repositorio local del fork realizado, pero en vuestro caso debéis acceder directamente al repositorio del fork

---

## Descripción del ejercicio (II)

- Debéis crear un pipeline en Jenkins que realice el despliegue de la aplicación en un contenedor Docker
- El despliegue de los dos contenedores Docker necesarios (Docker in Docker y Jenkins) debe realizarse mediante Terraform
- Para crear la imagen personalizada de Jenkins debéis usar un Dockerfile tal como hemos visto en clase, esto no debe realizarse mediante Terraform
- El despliegue desde el pipeline debe hacerse usando una rama llamada `main`

---

## Entrega del ejercicio (I)

- En la rama `main`, debéis crear una carpeta `docs` en la raíz del repositorio donde debéis incluir:
  - El Dockerfile para crear la imagen personalizada de Jenkins
  - Los archivos de configuración de Terraform
  - Un archivo llamado `README.md` con las instrucciones para replicar el proceso completo de despliegue: cómo crear la imagen de Jenkins, cómo desplegar los contenedores Docker con Terraform, cómo configurar Jenkins, etc.

---

## Entrega del ejercicio (II)

- Deben subirse a la tarea habilitada en el campus virtual los siguientes ficheros:
  - Un archivo txt con la URL de la rama `main` del repositorio de GitHub y vuestro nombre completo
  - Un vídeo explicativo de entre aproximadamente 6 y 8 minutos en calidad media (720p) donde se muestre el funcionamiento de la entrega.
    - El vídeo debe incluir la explicación de las configuraciones realizadas en cada fichero y mostrar el correcto funcionamiento del pipeline.
    - Debe mostrarse el proceso completo de despliegue, desde la creación de la imagen de Jenkins y el despliegue de contenedores con Terraform hasta la ejecución del pipeline
