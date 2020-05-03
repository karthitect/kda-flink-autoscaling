#!/bin/bash

REGION=us-east-2
STACK_NAME=kda-targettracking-scaling-stack1

if ! aws cloudformation describe-stacks --region $REGION --stack-name $STACK_NAME ; then

    echo -e "\nStack does not exist; creating stack for target tracking scaling..."
    aws cloudformation create-stack \
    --region $REGION \
    --stack-name $STACK_NAME \
    --on-failure DO_NOTHING \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --template-body file://targettracking-scaling.yaml

fi

# waiting for stack creation to complete...
echo -e "\nWaiting for stack creation to complete..."
aws cloudformation wait stack-create-complete \
    --region $REGION \
    --stack-name $STACK_NAME
echo -e "Stack creation complete"