pipeline {
    agent {
        kubernetes {
            label 'jenkins-agent-my-app'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: ci
spec:
  containers:
  - name: python
    image: python:3.7
    command:
    - cat
    tty: true
  - name: docker
    image: docker:24-dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    tty: true
"""
        }
    }
    triggers {
        pollSCM('* * * * *')
    }
    stages {
        stage('Test python') {
            steps {
                container('python') {
                    sh "pip install -r requirements.txt"
                    sh "python test.py"
                }
            }
        }

        stage('Build image') {
            steps {
                container('docker') {
                    sh """
                mkdir -p /etc/docker  # <-- Crée le dossier s'il n'existe pas
                echo '{"insecure-registries":["host.docker.internal:4000"]}' > /etc/docker/daemon.json
                service docker restart
                sleep 5  # Attendre que Docker redémarre
            """
                    sh "docker build -t host.docker.internal:4000/pythontest:latest ."
                    sh "docker push host.docker.internal:4000/pythontest:latest"
                }
            }
        }
    }
}