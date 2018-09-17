export AWS_DEFAULT_REGION=us-east-1
aws cloudformation create-stack --stack-name edx-vpc-stack --template-body file://vpc.template 
aws cloudformation wait stack-create-complete --stack-name edx-vpc-stack
VPC=$(aws cloudformation describe-stacks --stack-name edx-vpc-stack \
--query 'Stacks[0].Outputs[?OutputKey==`VPC`].OutputValue' --output text)
PublicSubnet1=$(aws cloudformation describe-stacks --stack-name edx-vpc-stack \
--query 'Stacks[0].Outputs[?OutputKey==`PublicSubnet1`].OutputValue' --output text)
SgGroupId=$(aws ec2 create-security-group \
--description exercise3-sg \
--group-name exercise4-sg \
--vpc-id $VPC \
--query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $SgGroupId \
--ip-permissions IpProtocol=tcp,FromPort=80,ToPort=80,IpRanges=' [{CidrIp=0.0.0.0/0}]'

aws iam create-instance-profile --instance-profile-name Webserver
aws iam create-role --role-name Webserver --assume-role-policy-document file://ec2-role-trust-policy.json
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM --role-name Webserver
aws iam add-role-to-instance-profile --role-name Webserver --instance-profile-name Webserver
sleep 5
InstanceId=$(aws ec2 run-instances \
--image-id ami-04681a1dbd79675a5 \
--count 1 \
--instance-type t2.micro \
--subnet-id $PublicSubnet1 \
--security-group-ids $SgGroupId \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Ex3WebServer}]' \
--iam-instance-profile Name=Webserver \
--user-data file://UserDataScript.txt \
--query 'Instances[0].InstanceId' --output text)

pip install awscli --upgrade --user
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm
