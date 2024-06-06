

## Pipeline para crear slides con Marp

Vamos a crear un pipeline para automatizar un proceso de creación de slides con Marp:
  - Marp es un framework para crear slides con Markdown
  - Usaremos un agente con la imagen de Docker `node:20.10.0-alpine3.18` que contiene Node.js y npm
  - Usaremos el contenido del repositorio https://github.com/uca-virtualizacion/devops/

Podemos acceder al repositorio de manera local o remota:
  - Si accedemos de manera local, el repositorio debe estar en el host
  - Si accedemos de manera remota, el repositorio debe estar en GitHub

Requisito para acceder de manera local:
  - Añadir `--volume "$HOME":/home` al docker run de jenkins-blueocean que usamos antes, para poder acceder a los archivos del host desde el contenedor.

1. Crear un fork del repositorio https://github.com/uca-virtualizacion/devops/ en tu cuenta de GitHub
2. Añadir al fork un archivo `Jenkinsfile` con el siguiente contenido:
  
```groovy
pipeline {
    
    agent {
        docker {
            image 'node:20.10.0-alpine3.18'
            args '-v /home/workspace/uca-virtualizacion/devops:/home/node/devops'
        }
    }

    environment {
        DEVOPS_PATH = '/home/workspace/uca-virtualizacion/devops'
        MOUNT_PATH = '/home/node/devops'
    }

    stages {
        stage('Install Marp') {
            steps {
                dir("marp") {
                    // Ejecutar npm install dentro del directorio 'marp'
                    sh 'npm install --save @marp-team/marp-core'
                }
            }
        }
        stage('Create Slides') {
            steps {
                // Crear el directorio 'slides' si no existe
                sh 'mkdir -p slides'
                // Ejecutar el script html-build.sh dentro de 'marp'
                sh './marp/html-build.sh cultura.md'
            }
        }
    }
}

```

---

## Pipeline para crear slides con Marp (repositorio local, sin credenciales)

Para acceder de manera local al repositorio debemos:
  1. Añadir `--volume "$HOME":/home` al docker run de jenkins-blueocean que usamos antes, para poder acceder a los archivos del host desde el contenedor.
  2. Añadir al docker run de jenkins-docker --env JAVA_OPTS="-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true" \
  3. Añadir `-v /home/workspace/uca-virtualizacion/devops:/home/node/devops` al agente de Docker del pipeline, para poder acceder a los archivos del host desde el agente de Docker.
  4. Configurar el Repositorio URL del pipeline para que apunte al repositorio local (por ejemplo, /home/workspace/uca-virtualizacion/vs-jenkins)
  5. No indicar credenciales
