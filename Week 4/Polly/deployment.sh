export AWS_DEFAULT_REGION=us-east-1
AWSAccountId=$(aws sts get-caller-identity --query 'Account' --output text)
SourceBucket=sourcebucket$AWSAccountId

aws s3api create-bucket --bucket $SourceBucket
sleep 5

cd code
aws s3 cp application.py s3://$SourceBucket/
aws s3 cp main.html s3://$SourceBucket/
cd ..

cp ../../Week\ 1/Exercise\ 3/vpc.yaml .
cp ../../Week\ 2/Exercise\ 5/iam.yaml .
cp ../../Week\ 4/Exercise\ 9/cdn.yaml .
cp ../../Week\ 4/Exercise\ 9/cfn.yaml .
cp ../../Week\ 4/Exercise\ 9/cloud9.yaml .
cp ../../Week\ 4/Exercise\ 9/cognito.yaml .
cp ../../Week\ 4/Exercise\ 9/db.yaml .
cp ../../Week\ 4/Exercise\ 9/parameters.yaml .
cp ../../Week\ 4/Exercise\ 9/web.yaml .
aws s3 sync . s3://$SourceBucket 
rm vpc.yaml
rm iam.yaml
rm cdn.yaml
rm cfn.yaml
rm cloud9.yaml
rm cognito.yaml
rm db.yaml
rm parameters.yaml
rm web.yaml

aws cloudformation update-stack --stack-name edx-project-stack \
--template-url https://s3.amazonaws.com/$SourceBucket/cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters    ParameterKey=Password,UsePreviousValue=true \
                ParameterKey=DBPassword,UsePreviousValue=true \
                ParameterKey=SourceBucket,UsePreviousValue=true \
                ParameterKey=AppDomain,UsePreviousValue=true
                
aws cloudformation wait stack-update-complete --stack-name edx-project-stack

InstanceIdWebServer1=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=WebServer1" \
--query 'Reservations[0].Instances[0].InstanceId' --output text)
InstanceIdWebServer2=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=WebServer2" \
--query 'Reservations[0].Instances[0].InstanceId' --output text)
CommandId=$(aws ssm send-command --document-name "AWS-RunShellScript" \
--comment "Update code" \
--instance-ids $InstanceIdWebServer1 $InstanceIdWebServer2 \
--parameters commands="service --status-all" \
--region $AWS_DEFAULT_REGION \
--output text --query "Command.CommandId")
sleep 10
aws ssm get-command-invocation --command-id $CommandId --instance-id $InstanceIdWebServer1
aws ssm get-command-invocation --command-id $CommandId --instance-id $InstanceIdWebServer2

pip install awscli --upgrade --user
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm
rm session-manager-plugin.rpm
