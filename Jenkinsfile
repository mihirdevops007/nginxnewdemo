pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="514523777807"
        AWS_DEFAULT_REGION="us-east-1" 
        CLUSTER_NAME="NginxDemo"
        SERVICE_NAME="nginx-samplenew"
	TASK_DEFINITION_NAME="nginx-sample"
        IMAGE_REPO_NAME="nginxdemo"
        IMAGE_TAG = "${env.BUILD_NAME}"
        IMAGE_VERSION = "${new Date().format('yyyyMMddHHmmss')}"      
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
    stage('Building image') {
      steps{
        script {
            withAWS(region: "${AWS_DEFAULT_REGION}", credentials: registryCredential) {
                sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPOSITORY_URI}/${IMAGE_REPO_NAME}" 
                dockerimage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
	      }         
	    }
          }
       }
	    //get-login --no-include-email
	    
    stage('Pushing to ECR') {
    steps {
        script {		
            withAWS(region: "${AWS_DEFAULT_REGION}", credentials: registryCredential) {
                sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${REPOSITORY_URI}/${IMAGE_REPO_NAME}" // Authenticate with ECR
  //               sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REPOSITORY}:${IMAGE_TAG}"
		// sh "sudo docker push ${ECR_REPOSITORY}:${IMAGE_TAG}" 
		sh "docker tag ${dockerimage}:${IMAGE_VERSION} ${REPOSITORY_URI}/${IMAGE_REPO_NAME}:${IMAGE_VERSION}" // Tag the Docker image
                sh "docker push ${REPOSITORY_URI}/${IMAGE_REPO_NAME}:${IMAGE_VERSION}" // Push the Docker image to ECR
           }
        }
      }
   }

    stage('Deploy') {
    steps {
        //withAWS(credentials: registryCredential, region: "${AWS_DEFAULT_REGION}") {
          //  script {
	        withAWS(region: "${AWS_DEFAULT_REGION}", credentials: registryCredential) {
                 sh "eval \$(aws ecr get-login --no-include-email --region ${AWS_DEFAULT_REGION})"
		 sh 'chmod +x /var/lib/jenkins/workspace/nginxdemo/script.sh'    
                 sh '/var/lib/jenkins/workspace/nginxdemo/script.sh'
		      }	
            }
          }
        //}
      //}
 
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
