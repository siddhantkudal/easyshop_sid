pipeline {
    agent any
    environment {
       email= "kudalsiddhant230@gamil.com" 
    }

    stages {
        stage('Clean WS') {
            steps {
                cleanWs();
            }
        }
        stage("Checkout CSM"){
            steps{
                git url:"https://github.com/siddhantkudal/easyshop_sid.git", branch: "master"
            }
        }
        stage("File system scan using Trivy"){
            steps{
                sh '''
                trivy fs --severity CRITICAL,HIGH --format table  . > trivy-output.txt
                ls -l
    
                '''
            }
        }
        stage("Parallel Build"){
            parallel {
                stage("Docker Build UI"){
                    steps{
                        script{
                             sh "docker build -t easyshop:${env.BUILD_NUMBER} ." 
                        }   
                        
                    }
                }
            }
            
        }
        stage("Docker Build Migration image"){
                    steps{
                        script {
                            sh "docker build -t docker_migrate:${env.BUILD_NUMBER} -f /var/lib/jenkins/workspace/EasyShop_CICD/Dockerfile.migrate  /var/lib/jenkins/workspace/EasyShop_CICD/ "
                        }
                    }
                }
        stage('Docker Push') {
            parallel {
                stage("UI image Push"){
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'dockertoken', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh """
                                echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                                docker tag easyshop:${env.BUILD_NUMBER} siddhantkudal/easyshop:${env.BUILD_NUMBER}
                                docker push siddhantkudal/easyshop:${env.BUILD_NUMBER}
                            """
                        }
                    }
                }
                stage("Migration image push"){
                    steps {
                        withCredentials([usernamePassword(credentialsId: 'dockertoken', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh """
                                docker tag docker_migrate:${env.BUILD_NUMBER} siddhantkudal/docker_migrate:${env.BUILD_NUMBER}
                                docker push siddhantkudal/docker_migrate:${env.BUILD_NUMBER}
                            """
                        }
                    }
                }
            }
            
        }
        stage("Update Manifies files"){
            steps{
                script {
                    withCredentials([usernamePassword(credentialsId: 'gittoken', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
    
                    sh """ 
                    git config user.name "${GIT_USER}"
                    git config user.email "${env.email}"
                    
                    sed -i "s|image: siddhantkudal/easyshop:.*|image: siddhantkudal/easyshop:${env.BUILD_NUMBER}|g" kubernetes/easyshop_frontend_deployment.yml
                    sed -i "s|image: siddhantkudal/docker_migrate:.*|image: siddhantkudal/docker_migrate:${env.BUILD_NUMBER}|g" kubernetes/mongodb_deployment.yml
                    
                    if git diff --quiet; then
                        echo "No changes to commit"
                    else
                        git add kubernetes/.
                        git commit -m "Updated manifiest files"
                        git remote set-url origin https://"${GIT_USER}":"${GIT_PASS}"@github.com/siddhantkudal/easyshop_sid.git
                        git push origin master
                    fi
                    
                    """
                    }
                }
            }
        }
    }
}
