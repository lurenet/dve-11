#!/usr/bin/env groovy

pipeline {
    
    agent none
    
    environment {
        IMAGE_BASE = '34.118.18.14:8123/webapp'
        IMAGE_TAG = "latest"
        IMAGE_NAME = "${env.IMAGE_BASE}:${env.IMAGE_TAG}"
        IMAGE_NAME_LATEST = "${env.IMAGE_BASE}:latest"
        DOCKERFILE_NAME = "Dockerfile"
    }

    stages {
        
        stage('prepare container') {
            
            agent {
                docker {
                    image '34.118.18.14:8123/webapp-build:latest'
                    args '--privileged -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.m2:/root/.m2'
                }
            }
            
            stages {
                
                stage ('git') {
                    steps {
                        git branch: 'main', url: 'https://github.com/lurenet/dve-11.git'
                    }
                }
                
                stage ('build & push to registry') {
                    steps {
                        script {
                            def dockerImage = docker.build("${env.IMAGE_NAME}", "-f ${env.DOCKERFILE_NAME} .")
                            docker.withRegistry('http://34.118.18.14:8123', 'b0e404f5-7d7d-46af-8a4a-02fa56769942') {
                                dockerImage.push()
                            }
                            echo "Pushed Docker Image: ${env.IMAGE_NAME}"
                        }
                        sh "docker rmi ${env.IMAGE_NAME}"
                    }
                    
                }
                
            }
      
        } 
        
        stage ('pull image & run container') {
            
            agent any
            
            steps {
                script {
                    def remote = [:]
                    remote.name = 'prod'
                    remote.host = '35.205.200.65'
                    withCredentials([usernamePassword(credentialsId: 'b7eafe6e-a0fa-4f19-ac23-5228f26eec5f', passwordVariable: 'rpasswd', usernameVariable: 'ruser')]) {
                        remote.user = "${ruser}"
                        remote.password = "${rpasswd}"
                    }
                    remote.allowAnyHosts = true
                    sshCommand remote: remote, command: "apt update && apt install -y docker.io"
                    writeFile file: 'insecure.sh', text: '{"insecure-registries":["34.118.18.14:8123"]}\n'
                    sshPut remote: remote, from: 'insecure.sh', into: '/etc/docker/daemon.json'
                    sshCommand remote: remote, command: "systemctl restart docker"
                    sshCommand remote: remote, command: "docker run -d -p 80:8080 34.118.18.14:8123/webapp:latest"
                }
            }
        }
        
    }
}
