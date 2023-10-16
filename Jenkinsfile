// pipeline {
//     agent any
//     environment {
//         // AWS region where the ECR repository and ECS cluster are located
//         AWS_REGION = 'us-east-1'
//         // Amazon Elastic Container Registry (ECR) repository where the Docker image will be pushed
//         ECR_REPOSITORY = '514523777807.dkr.ecr.us-east-1.amazonaws.com/nginxdemo'
//         // Amazon Elastic Container Service (ECS) cluster where the task definition will be deployed
//         ECS_CLUSTER = 'NginxDemo'
//         // Amazon Elastic Container Service (ECS) service that will be updated with the latest task definition
//         ECS_SERVICE = 'nginx-v1'
//         // Amazon Elastic Container Service (ECS) task definition that will be updated with the latest Docker image
//         ECS_TASK_DEFINITION = 'nginx-dev'
//         // Name of the Docker image to pull from Docker Hub
//         IMAGE_NAME = 'nginxdemonew'
//         // Version of the Docker image to pull from Docker Hub
//         IMAGE_VERSION = 'latest-v1'
//         // Version of the ecr image to pull from Docker Hub
//         ECR_IMAGE_VERSION = '2.0.0'
//         // ECS Task Defination
//         TASK_DEF_FILE= '/home/dev.json'

//     }
//     stages {
//         stage('Git Cloning') {
//             steps {
//                git branch: 'mainapi', credentialsId: '704774a1-01f0-45d9-9974-a88892be6a3a', url: 'https://github.com/gully-champs/Gully-champs.git'
//                 // Chnage directory
//             }
//         }
//         stage('Docker Build image') {
//             steps {
               
//                 sh "sudo docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} ."
//             }
//         }
//         stage('Push image to ECR') {
//             steps {
               
//                     // Log in to Amazon ECR to push the Docker image to the specified ECR repository
//                     sh "sudo aws ecr get-login-password --region ap-south-1 | sudo docker login --username AWS --password-stdin 180221202673.dkr.ecr.ap-south-1.amazonaws.com"
//                     // Tag the Docker image with the ECR repository and version
//                     sh "sudo docker tag ${IMAGE_NAME}:${IMAGE_VERSION} ${ECR_REPOSITORY}:${ECR_IMAGE_VERSION}"
//                     // Push the Docker image to the specified ECR repository
//                     sh "sudo docker push ${ECR_REPOSITORY}:${ECR_IMAGE_VERSION}"
               
//             }
//         }
//         stage('Update ECS Task Definition') {
//             steps {
//                 sh '''
//                     sudo cat $TASK_DEF_FILE  | sudo jq '.containerDefinitions[0].image = "'"$ECR_REPOSITORY"':'"$ECR_IMAGE_VERSION"'"' > temp.json> temp.json && sudo mv temp.json $TASK_DEF_FILE
//                     sudo aws ecs register-task-definition --cli-input-json file://$TASK_DEF_FILE --family ${ECS_TASK_DEFINITION}
//                   '''

//             }

//         }
//         stage('Test scripts') {
//             steps {
//                 sh '''
//                      echo hello
//                   '''

//             }

//         }

//         stage('Deploy latest Image on ECS') {
//             steps {
//                     // Deploy the latest task definition to the specified ECS service
//                     sh "sudo aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --task-definition ${ECS_TASK_DEFINITION}"
//             }
//         }
//     }
// }

pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="514523777807"
        AWS_DEFAULT_REGION="us-east-1" 
	CLUSTER_NAME="NginxDemo"
        SERVICE_NAME="nginx-service"
	TASK_DEFINITION_NAME="nginx-dev"
        //DESIRED_COUNT="1"
        IMAGE_REPO_NAME="nginxdemo"
        IMAGE_TAG="${env.BUILD_ID}"
        //ECR_IMAGE_VERSION = '2.0.0' 
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
	registryCredential = "nginxaws"
    }
   
    stages {

    // Tests
    // stage('Unit Tests') {
    //   steps{
    //     script {
    //       sh 'npm install'
	   //      sh 'npm test -- --watchAll=false'
    //     }
    //   }
    // }
        
    // Building Docker images
    	    
    stage('Building image') {
      steps{
        script {
          dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
        }
      }
    }
	    //get-login --no-include-email
    stage('Pushing to ECR') {
    steps {
        script {
	    // sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 514523777807.dkr.ecr.us-east-1.amazonaws.com" 	
	    // sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:${ECR_IMAGE_VERSION}" 
     //        sh "docker push ${ECR_REPOSITORY}:${ECR_IMAGE_VERSION}"		
            withAWS(region: "${AWS_DEFAULT_REGION}", credentials: registryCredential) {
                sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 514523777807.dkr.ecr.us-east-1.amazonaws.com" // Authenticate with ECR
                sh "docker tag ${dockerImage.id} ${REPOSITORY_URI}/${IMAGE_REPO_NAME}:${IMAGE_TAG}" // Tag the Docker image
                sh "docker push ${REPOSITORY_URI}/${IMAGE_REPO_NAME}:${IMAGE_TAG}" // Push the Docker image to ECR
           }
        }
      }
   }

    stage('Deploy') {
    steps {
        withAWS(credentials: registryCredential, region: "${AWS_DEFAULT_REGION}") {
            script {
	        // withAWS(region: "${AWS_DEFAULT_REGION}", credentials: registryCredential) {
         //            sh "eval \$(aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION})"
		    sh 'chmod +x /var/lib/jenkins/workspace/nginxdemo/script.sh'    
                    sh '/var/lib/jenkins/workspace/nginxdemo/script.sh'
		//}	
            }
          }
        }
      }
 
    // Uploading Docker images into AWS ECR
   //  stage('Pushing to ECR') {
   //   steps{  
   //       script {
	  //  docker.withRegistry("https://" + REPOSITORY_URI, "ecr:${AWS_DEFAULT_REGION}", + registryCredential) {
	  //  //docker.withRegistry("https://" + REPOSITORY_URI, "ecr:${AWS_DEFAULT_REGION}:", registryCredential) {
	  //  dockerImage.push()
   //   	  }
   //       }
   //      }
   //    }
      
   //  stage('Deploy') {
   //   steps{
   //          withAWS(credentials: registryCredential, region: "${AWS_DEFAULT_REGION}") {
   //              script {
			// sh './script.sh'
   //              }
   //          } 
   //      }
   //    }      
      
    }
 }
