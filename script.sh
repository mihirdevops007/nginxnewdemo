#!/bin/bash

# Set your AWS region and other variables
TASK_DEFINITION_NAME="adminnew"
AWS_DEFAULT_REGION="ap-northeast-1"
#IMAGE_TAG="${env.BUILD_ID}"
REPOSITORY_URI="543050024229.dkr.ecr.ap-northeast-1.amazonaws.com"
CLUSTER_NAME="nodejs"
SERVICE_NAME="nodejs_service"
DESIRED_COUNT=1  # Set your desired count

# Get the task definition information
task_definition_info=$(aws ecs describe-task-definition --task-definition "$TASK_DEFINITION_NAME" --region "$AWS_DEFAULT_REGION")

ROLE_ARN="arn:aws:iam::543050024229:role/ecsTaskExecutionRole"  # Hardcoded from your task definition
FAMILY="Web-app"  # Hardcoded from your task definition
NAME="Web-app"  # Hardcoded from your task definition

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
echo "REVISION= $REVISION"

# Update the service to use the new task definition
aws ecs update-service --cluster "$CLUSTER_NAME" --service "$SERVICE_NAME" --task-definition "$TASK_DEFINITION_NAME:$REVISION" --desired-count "$DESIRED_COUNT"

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
