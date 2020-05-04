## Warning: Guidance in alpha stage
NOTE: This guidance (especially on target tracking scaling) is still a work in progress.

## Overview
This sample is meant to help users auto-scale their [Kinesis Data Analytics for Java](https://aws.amazon.com/kinesis/data-analytics/) (KDA) applications using [AWS Application Autoscaling](https://docs.aws.amazon.com/autoscaling/application/userguide/what-is-application-auto-scaling.html). KDA currently only supports CPU based autoscaling, and readers can use the guidance in this repo to scale their KDA applications based on other signals - such as operator throughput, for instance.

We've included guidance for both [step scaling](https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-step-scaling-policies.html) and [target tracking scaling](https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-target-tracking.html). For official documentation on AWS Application Autoscaling, please visit:
- [Step scaling](https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-step-scaling-policies.html)
- [Target tracking scaling](https://docs.aws.amazon.com/autoscaling/application/userguide/application-auto-scaling-target-tracking.html)

## Why use Application Autoscaling?
You may be wondering: "Why use Application Autoscaling; why not just trigger a Lambda function via a CloudWatch alarm and SNS?". The main reason is that Application Autoscaling has a well defined API for specifying scaling policies and associated attributes such as cooldown periods. In addition, we can take advantage of the various types of scaling types included with Application Autoscaling: step scaling, target tracking scaling, and schedule-based scaling (not covered in this doc).


## Step scaling
The step scaling sample uses the incomingRecords metrics for the source Kinesis stream to proportionately configure the parallelism of the associated KDA application. The following subsections describe the key components behind the scaling approach

### Application autoscaling of custom resource

Application autoscaling allows users to scale in/out custom resources by specifying a custom endpoint that can be invoked by Application Autoscaling. In this example, this custom endpoint is implemented using API Gateway and an AWS Lambda function. Here's a high level flow depicting this approach:

CW Alarm => Application Autoscaling => Custom Endpoint (API GW + Lambda) => Scale KDA App

### CloudFormation template
The accompanying [CloudFormation template](https://github.com/karthitect/kda-flink-autoscaling/blob/master/step-scaling/step-scaling.yaml) takes care of provisioning all of the above components.

### Scaling logic
When invoked by Application Autoscaling, the Lambda function (written in Python) will call [UpdateApplication](https://docs.aws.amazon.com/kinesisanalytics/latest/apiv2/API_UpdateApplication.html) with the desired capacity specified. In addition, it will also re-configure the alarm thresholds to take into account the current parallelism of the KDA application.

You can review the Python code for the Lambda function [here](https://github.com/karthitect/kda-flink-autoscaling/blob/master/step-scaling/index.py).

### Some caveats

1. When scaling out/in, in this sample we only update the overall parallelism; we don't adjust parallelism/KPU.
2. When scaling occurs, the KDA app experiences downtime. Please take this into consideration, when configuring the step scaling increments.
3. Please keep in mind that the throughput of a Flink application is dependent on many factors (complexity of processing, destination throughput, etc...). This example assumes a simple relationship between incoming record throughput and scaling for demonstration purposes.

## Target tracking scaling
[In progress]