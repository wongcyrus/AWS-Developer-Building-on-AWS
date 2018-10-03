# AWS-Developer-Building-on-AWS


Alternative solution to complete lab exercises for the edx course.


AWS Academy Sandbox Lab, please set additional Permission.


1. Add the below permssison to awsstudent's lab_policy


"cognito-idp:\*", "ssm:\*", "lambda:\*", "cognito-sync:\*", "cloud9:\*", "cognito-identity:\*", "apigateway:\*", "polly:SynthesizeSpeech","xray:\*",


2. Remove deny delete vpc and subnet in line policy default_policy of awsstudent.


"ec2:DeleteVpc","ec2:DeleteSubnet",