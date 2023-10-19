#!/bin/bash

# Set your AWS region and other variables
AWS_ACCOUNT_ID="514523777807"
TASK_DEFINITION_NAME="nginx-sample"
AWS_DEFAULT_REGION="us-east-1"
REPOSITORY_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_VERSION}"
CLUSTER_NAME="NginxDemo"
SERVICE_NAME="nginx-samplenew"
DESIRED_COUNT=1
IMAGE_REPO_NAME="nginxdemo"
TASK_DEFINITION_FILE="/var/lib/jenkins/workspace/nginxdemo/task-definition.json"

# Get the task definition information
task_definition_info=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION_NAME" --region "$AWS_DEFAULT_REGION")

# Retrieve the latest image tag from ECR
# Retrieve the latest image URL from ECR

# Check if the task definition exists and proceed if it does
if [ $? -eq 0 ]; then
    # Extract the execution role ARN and family from the task definition
    ROLE_ARN=$(echo "$task_definition_info" | jq -r '.taskDefinition.executionRoleArn')
    FAMILY=$(echo "$task_definition_info" | jq -r '.taskDefinition.family')
    #IMAGE_TAG_PLACEHOLDER=$(echo "$task_definition_info" | jq -r '.taskDefinition.image')
    NAME=$(echo "$task_definition_info" | jq -r '.taskDefinition.containerDefinitions[0].name')
    LATEST_IMAGE_URL=$(aws ecr describe-images --repository-name $IMAGE_REPO_NAME --query 'images | [0].imageUri' --output text --region $AWS_REGION)
    
    # Update placeholders in task-definition.json
    
    sed -i "s#ROLE_ARN#$ROLE_ARN#g" task-definition.json
    sed -i "s#FAMILY#$FAMILY#g" task-definition.json
    #sed -i "s#REPOSITORY_URI#$IMAGE#g" task-definition.json    
    sed -i "s|IMAGE_TAG_PLACEHOLDER|$LATEST_IMAGE_URL|g" task-definition.json
    sed -i "s#NAME#$IMAGE_REPO_NAME#g" task-definition.json
    
  
    # Register the updated task definition
    aws ecs register-task-definition --cli-input-json file://${TASK_DEFINITION_FILE} --region "$AWS_DEFAULT_REGION"

    # Get the new revision number
    REVISION=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION_NAME" --region "$AWS_DEFAULT_REGION" | jq -r '.taskDefinition.revision')

    # Check if a valid revision number is obtained
    if [ "$REVISION" != "null" ]; then
        echo "REVISION= $REVISION"

        # Update the service to use the new task definition
        aws ecs update-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --task-definition "$TASK_DEFINITION_NAME:$REVISION" --desired-count "$DESIRED_COUNT"
    else
        echo "Failed to obtain a valid task definition revision number."
    fi
else
    echo "Task definition not found. Please check if it exists and the name is correct."
fi



# #!/bin/bash
# # Set your AWS region and other variables
# AWS_ACCOUNT_ID="514523777807"
# TASK_DEFINITION_NAME="nginx-dev"
# TASK_DEFINITION_ARN="arn:aws:ecs:us-east-1:514523777807:task-definition/nginx-dev:$REVISION"
# AWS_DEFAULT_REGION="us-east-1"
# IMAGE_REPO_NAME="nginxdemo"
# #IMAGE_TAG="${env.BUILD_ID}"
# REPOSITORY_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
# CLUSTER_NAME="NginxDemo"
# SERVICE_NAME="nginx-service"
# DESIRED_COUNT=1  # Set your desired count


# # Get the task definition information
# task_definition_info=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION_NAME" --region "$AWS_DEFAULT_REGION")

# # Check if the task definition exists and proceed if it does
# if [ $? -eq 0 ]; then
#     #ROLE_ARN="arn:aws:iam::543050024229:role/AmazonECSTaskExecutionRolePolicy"  # Hardcoded from your task definition
#     ROLE_ARN="arn:aws:iam::514523777807:role/JeenkinsCICD_EC2"
#     FAMILY="nginx-dev"  # Hardcoded from your task definition
#     NAME="nginx-dev"  # Hardcoded from your task definition

#     # Update placeholders in task-definition.json
#     sed -i "s#BUILD_NUMBER#$IMAGE_TAG#g" task-definition.json
#     sed -i "s#REPOSITORY_URI#$REPOSITORY_URI#g" task-definition.json
#     sed -i "s#ROLE_ARN#$ROLE_ARN#g" task-definition.json
#     sed -i "s#FAMILY#$FAMILY#g" task-definition.json
#     sed -i "s#NAME#$NAME#g" task-definition.json

#     # Register the updated task definition
#     aws ecs register-task-definition --cli-input-json file://task-definition.json --region="$AWS_DEFAULT_REGION"

#     # Get the new revision number
#     REVISION=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION_NAME" --region "$AWS_DEFAULT_REGION" | jq -r '.taskDefinition.revision')

#     # Check if a valid revision number is obtained
#     if [ "$REVISION" != "null" ]; then
#         echo "REVISION= $REVISION"

#         # Update the service to use the new task definition
#         #cat $TASK_DEF_FILE  | sudo jq '.containerDefinitions[0].image = "'"$ECR_REPOSITORY"':'"$ECR_IMAGE_VERSION"'"' > temp.json> temp.json && sudo mv temp.json $TASK_DEF_FILE
#         aws ecs update-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --task-definition "$TASK_DEFINITION_NAME" --desired-count "$DESIRED_COUNT"
#     else
#         echo "Failed to obtain a valid task definition revision number."
#     fi
# else
#     echo "Task definition not found. Please check if it exists and the name is correct."
# fi

# # #!/bin/bash

# # ROLE_ARN=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.executionRoleArn`
# # echo "ROLE_ARN= " $ROLE_ARN

# # FAMILY=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.family`
# # echo "FAMILY= " $FAMILY

# # NAME=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.containerDefinitions[].name`
# # echo "NAME= " $NAME

# # sed -i "s#BUILD_NUMBER#$IMAGE_TAG#g" task-definition.json
# # sed -i "s#REPOSITORY_URI#$REPOSITORY_URI#g" task-definition.json
# # sed -i "s#ROLE_ARN#$ROLE_ARN#g" task-definition.json
# # sed -i "s#FAMILY#$FAMILY#g" task-definition.json
# # sed -i "s#NAME#$NAME#g" task-definition.json


# # aws ecs register-task-definition --cli-input-json file://task-definition.json --region="${AWS_DEFAULT_REGION}"

# # REVISION=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.revision`
# # echo "REVISION= " "${REVISION}"
# # aws ecs update-service --cluster "${CLUSTER_NAME}" --service "${SERVICE_NAME}" --task-definition "${TASK_DEFINITION_NAME}":"${REVISION}" --desired-count "${DESIRED_COUNT}"
