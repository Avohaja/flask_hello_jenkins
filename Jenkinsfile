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
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
  - name: docker
    image: docker:dind  # <-- Utilisation de docker:dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
  volumes:
  - name: workspace-volume
    emptyDir: {}
"""
        }
    }
    triggers {
        pollSCM('* * * * *')
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Test Python') {
            steps {
                container('python') {
                    sh 'pip install -r requirements.txt'
                    sh 'python test.py'
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                container('docker') {
                    // Configure le registry comme insecure
                    sh """
                        mkdir -p /etc/docker
                        echo '{"insecure-registries":["host.docker.internal:4000"]}' > /etc/docker/daemon.json
                        // Redémarre dockerd (spécifique à docker:dind)
                        pkill dockerd || true
                        sleep 2
                        dockerd --insecure-registry=host.docker.internal:4000 &
                        sleep 10  // Attendre que Docker soit prêt
                    """
                    // Construit l'image
                    sh 'docker build -t host.docker.internal:4000/pythontest:latest .'
                    // Pousse l'image vers le registry local
                    sh 'docker push host.docker.internal:4000/pythontest:latest'
                }
            }
        }
    }
}