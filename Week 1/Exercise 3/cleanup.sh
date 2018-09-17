aws ec2 terminate-instances --instance-ids $InstanceId
aws cloudformation delete-stack --stack-name edx-vpc-stack