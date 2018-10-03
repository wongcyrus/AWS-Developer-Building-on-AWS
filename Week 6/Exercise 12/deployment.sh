export AWS_DEFAULT_REGION=us-east-1
AWSAccountId=$(aws sts get-caller-identity --query 'Account' --output text)
SourceBucket=sourcebucket$AWSAccountId

aws s3api create-bucket --bucket $SourceBucket
sleep 5

cp ../../Week\ 1/Exercise\ 3/vpc.yaml .
cp ../../Week\ 2/Exercise\ 5/iam.yaml .
cp ../../Week\ 4/Exercise\ 9/cdn.yaml .
cp ../../Week\ 4/Exercise\ 9/cloud9.yaml .
cp ../../Week\ 4/Exercise\ 9/cognito.yaml .
cp ../../Week\ 4/Exercise\ 9/parameters.yaml .
cp ../../Week\ 5/Exercise\ 10/web.yaml .
cp ../../Week\ 5/Exercise\ 11/db.yaml .
cp ../../Week\ 5/Exercise\ 11/security.yaml .
aws s3 sync . s3://$SourceBucket 
rm vpc.yaml
rm iam.yaml
rm cdn.yaml
rm cloud9.yaml
rm cognito.yaml
rm parameters.yaml
rm web.yaml
rm db.yaml
rm security.yaml

wget https://us-west-2-tcdev.s3.amazonaws.com/courses/AWS-100-ADG/v1.1.0/exercises/ex-sns-sqs.zip
unzip -o ex-sns-sqs.zip
rm ex-sns-sqs.zip
yes | cp -f ../../Week\ 4/Exercise\ 9/code/config.py exercise-sns-sqs/FlaskApp/
yes | cp -f ../../Week\ 3/Exercise\ 8/code/database_create_tables.py exercise-sns-sqs/Deploy/
yes | cp -f ../../Week\ 4/Exercise\ 9/code/nginx.conf exercise-sns-sqs/Deploy/
yes | cp -f ../../Week\ 4/Polly/code/app.ini exercise-sns-sqs/Deploy/
cd exercise-sns-sqs
zip -ro deploy-app.zip Deploy/ FlaskApp/
aws s3 cp deploy-app.zip s3://$SourceBucket/
pip-3.6 install 'mysql_connector_python<8.1' -t LambdaImageLabels
cd LambdaImageLabels
zip -r lambda.zip *
aws s3 cp lambda.zip s3://$SourceBucket/
cd ../../
rm -rf exercise-sns-sqs

## For new Stack Creation
# random=$(shuf -i 2000-65000 -n 1)
# aws cloudformation create-stack --stack-name edx-project-stack --template-body file://cfn.yaml \
# --capabilities CAPABILITY_NAMED_IAM \
# --parameters    ParameterKey=Password,ParameterValue=P@ssword \
#                 ParameterKey=DBPassword,ParameterValue=Password \
#                 ParameterKey=SourceBucket,ParameterValue=$SourceBucket \
#                 ParameterKey=AppDomain,ParameterValue=uniqueedx$AWSAccountId$random
# aws cloudformation wait stack-create-complete --stack-name edx-project-stack


## For Stack update for previous exercise. You need to run all of the below commands.
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
--comment "Deploy new code." \
--instance-ids $InstanceIdWebServer1 $InstanceIdWebServer2 \
--parameters commands=["sudo stop uwsgi",\
"sudo rm -rf /photos",\
"sudo mkdir /photos",\
"cd /photos",\
"sudo aws s3 cp s3://$SourceBucket/deploy-app.zip .",\
"sudo unzip deploy-app.zip",\
"sudo pip-3.6 install -r FlaskApp/requirements.txt",\
"sudo start uwsgi"] \
--region $AWS_DEFAULT_REGION \
--output text --query "Command.CommandId")
sleep 5
aws ssm get-command-invocation --command-id $CommandId --instance-id $InstanceIdWebServer1
aws ssm get-command-invocation --command-id $CommandId --instance-id $InstanceIdWebServer2

LabelsLambda=$(aws cloudformation describe-stacks --stack-name edx-project-stack \
--query 'Stacks[0].Outputs[?OutputKey==`LabelsLambda`].OutputValue' --output text)
aws lambda update-function-code --function-name $LabelsLambda --s3-bucket $SourceBucket --s3-key lambda.zip

