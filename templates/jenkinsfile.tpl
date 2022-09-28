pipeline {
    agent any
    // environment {
    //     AWS_ACCOUNT_ID="${aws_account_id}"
    //     AWS_DEFAULT_REGION="${aws_default_region}" 
    //     IMAGE_REPO_NAME="${image_repo_name}"
    //     IMAGE_TAG="${image_tag}"
    //     REPOSITORY_URI = "${repository_uri}"
    //     EKS_CLUSTER_NAME = "${eks_cluster_name}"
    // }
    options {
        skipStagesAfterUnstable()
    }
    stages {
        
        stage('Logging into AWS ECR'){
            steps{
                script{
                    sh "aws ecr get-login-password --region ${aws_default_region} | docker login --username AWS --password-stdin ${aws_account_id}.dkr.ecr.${aws_default_region}.amazonaws.com"
                }
            }
        }
        
         stage('Clone repository') { 
            steps { 
                script{
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: '${github_url}']]])
                }
            }
        }

        stage('Building image') { 
            steps { 
                script{
                 dockerImage = docker.build "${image_repo_name}:${image_tag}"
                }
            }
        }
        stage('Test'){
            steps {
                 echo 'Empty'
            }
        }
        stage('Pusing to ECR') {
            steps {
                script{
                    sh "docker tag ${image_repo_name}:${image_tag} ${repository_uri}:${image_tag}"
                    sh "docker push ${aws_account_id}.dkr.ecr.${aws_default_region}.amazonaws.com/${image_repo_name}:${image_tag}"
                }
            }
        }
        stage('Deploying to EKS') {
            steps {
                script{
                    sh "aws eks update-kubeconfig --region ${aws_default_region} --name ${eks_cluster_name}"
                    try{
                        sh "kubectl create ns ${image_repo_name}"
                        sh "kubectl delete -f deployment.yaml"
                    }    
                    catch (err){
                        
                    }
                    sh "kubectl apply -f deployment.yaml"
                }
            }
        }
    }
}