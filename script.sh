#!/bin/bash

# Set your AWS region and other variables
AWS_ACCOUNT_ID="514523777807"
TASK_DEFINITION_NAME="nginx-dev"
AWS_DEFAULT_REGION="us-east-1"
#IMAGE_TAG="${env.BUILD_ID}"
REPOSITORY_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
CLUSTER_NAME="NginxDemo"
SERVICE_NAME="nginx-v1"
DESIRED_COUNT=1  # Set your desired count


# Get the task definition information
task_definition_info=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION_NAME" --region "$AWS_DEFAULT_REGION")

# Check if the task definition exists and proceed if it does
if [ $? -eq 0 ]; then
    #ROLE_ARN="arn:aws:iam::543050024229:role/AmazonECSTaskExecutionRolePolicy"  # Hardcoded from your task definition
    ROLE_ARN="arn:aws:iam::514523777807:role/JeenkinsCICD_EC2"
    FAMILY="nginx-app"  # Hardcoded from your task definition
    NAME="nginx-app"  # Hardcoded from your task definition

    # Update placeholders in task-definition.json
    sed -i "s#BUILD_NUMBER#$IMAGE_TAG#g" task-definition.json
    sed -i "s#REPOSITORY_URI#$REPOSITORY_URI#g" task-definition.json
    sed -i "s#ROLE_ARN#$ROLE_ARN#g" task-definition.json
    sed -i "s#FAMILY#$FAMILY#g" task-definition.json
    sed -i "s#NAME#$NAME#g" task-definition.json

    # Register the updated task definition
    aws ecs register-task-definition --cli-input-json file://task-definition.json --region="$AWS_DEFAULT_REGION"

    # Get the new revision number
    REVISION=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION_NAME" --region "$AWS_DEFAULT_REGION" | jq -r '.taskDefinition.revision')

    # Check if a valid revision number is obtained
    if [ "$REVISION" != "null" ]; then
        echo "REVISION= $REVISION"

        # Update the service to use the new task definition
        #cat $TASK_DEF_FILE  | sudo jq '.containerDefinitions[0].image = "'"$ECR_REPOSITORY"':'"$ECR_IMAGE_VERSION"'"' > temp.json> temp.json && sudo mv temp.json $TASK_DEF_FILE
        aws ecs update-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --task-definition "$TASK_DEFINITION_NAME:$REVISION" --desired-count "$DESIRED_COUNT"
    else
        echo "Failed to obtain a valid task definition revision number."
    fi
else
    echo "Task definition not found. Please check if it exists and the name is correct."
fi

# #!/bin/bash

# ROLE_ARN=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.executionRoleArn`
# echo "ROLE_ARN= " $ROLE_ARN

# FAMILY=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.family`
# echo "FAMILY= " $FAMILY

# NAME=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.containerDefinitions[].name`
# echo "NAME= " $NAME

# sed -i "s#BUILD_NUMBER#$IMAGE_TAG#g" task-definition.json
# sed -i "s#REPOSITORY_URI#$REPOSITORY_URI#g" task-definition.json
# sed -i "s#ROLE_ARN#$ROLE_ARN#g" task-definition.json
# sed -i "s#FAMILY#$FAMILY#g" task-definition.json
# sed -i "s#NAME#$NAME#g" task-definition.json


# aws ecs register-task-definition --cli-input-json file://task-definition.json --region="${AWS_DEFAULT_REGION}"

# REVISION=`aws ecs describe-task-definition --task-definition "${TASK_DEFINITION_NAME}" --region "${AWS_DEFAULT_REGION}" | jq .taskDefinition.revision`
# echo "REVISION= " "${REVISION}"
# aws ecs update-service --cluster "${CLUSTER_NAME}" --service "${SERVICE_NAME}" --task-definition "${TASK_DEFINITION_NAME}":"${REVISION}" --desired-count "${DESIRED_COUNT}"
