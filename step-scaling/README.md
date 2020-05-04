## Step scaling
The step scaling sample uses the incomingRecords metric for the source Kinesis stream to proportionately configure the parallelism of the associated KDA application. The following subsections describe the key components behind the scaling approach

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
2. When scaling occurs, the KDA app experiences downtime. Please take this into consideration when configuring the step scaling increments.
3. Please keep in mind that the throughput of a Flink application is dependent on many factors (complexity of processing, destination throughput, etc...). This example assumes a simple relationship between incoming record throughput and scaling for demonstration purposes.