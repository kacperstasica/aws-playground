#!/bin/bash
shopt -s expand_aliases
alias aws='aws-vault exec $profile -- aws'
aws ecs list-tasks --cluster django-aws-prod
echo "HELLO"

TASK_ID=$(aws ecs list-tasks --cluster django-aws-prod --service-name prod-backend-web  --query 'taskArns[0]' --output text  | awk '{split($0,a,"/"); print a[3]}')
echo "AGAIN"
echo $TASK_ID
aws ecs execute-command --task $TASK_ID --command "bash" --interactive --cluster django-aws-prod --region eu-central-1