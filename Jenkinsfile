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
                    sh "docker build -t localhost:4000/pythontest:latest ."
                    sh "docker push localhost:4000/pythontest:latest"
                }
            }
        }
    }
}