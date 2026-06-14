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
    - name: kubectl
    image: lachlanevenson/k8s-kubectl:v1.17.2 # use a version that match
    command:
    - cat
    tty: true
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
                    // 1. Configure le registry comme insecure
                    sh """
                        mkdir -p /etc/docker
                        printf '{"insecure-registries":["host.docker.internal:4000"]}' > /etc/docker/daemon.json
                    """
                    // 2. Redémarre dockerd avec la nouvelle configuration
                    //    (docker:dind gère déjà dockerd, donc on envoie un signal SIGHUP pour recharger la config)
                    sh """
                        kill -HUP 1 || true  # Envoie un signal SIGHUP au PID 1 (dockerd) pour recharger la config
                        sleep 5  # Attend que la config soit rechargée
                    """
                    // 3. Vérifie que Docker est prêt
                    sh "docker info | grep -i 'insecure'"
                    // 4. Construit et pousse l'image
                    sh "docker build -t host.docker.internal:4000/pythontest:latest ."
                    sh "docker push host.docker.internal:4000/pythontest:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                container('kubectl') {
                    sh "kubectl apply -f ./kubernetes/deployment.yaml"
                    sh "kubectl apply -f ./kubernetes/service.yaml"
                }
            }
        }

    }
}