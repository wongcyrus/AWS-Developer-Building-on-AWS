export AWS_DEFAULT_REGION=us-east-1
AWSAccountId=$(aws sts get-caller-identity --query 'Account' --output text)
SourceBucket=sourcebucket$AWSAccountId

aws s3api create-bucket --bucket $SourceBucket
sleep 5

wget https://us-west-2-tcdev.s3.amazonaws.com/courses/AWS-100-ADG/v1.1.0/exercises/ex-cognito.zip
unzip -o ex-cognito.zip
rm ex-cognito.zip
yes | cp -f code/config.py exercise-cognito/FlaskApp/
yes | cp -f code/database_create_tables.py exercise-cognito/Deploy/
cd exercise-cognito
zip -ro deploy-app.zip Deploy/ FlaskApp/
aws s3 cp deploy-app.zip s3://$SourceBucket/
cd ..
rm -rf exercise-cognito

cp ../../Week\ 1/Exercise\ 3/vpc.yaml .
cp ../../Week\ 2/Exercise\ 5/iam.yaml .
aws s3 sync . s3://$SourceBucket 
rm vpc.yaml
rm iam.yaml


# aws cloudformation update-stack --stack-name edx-project-stack \
# --template-url https://s3.amazonaws.com/$SourceBucket/cfn.yaml \
aws cloudformation create-stack --stack-name edx-project-stack --template-body file://cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters    ParameterKey=Password,ParameterValue=P@ssword \
                ParameterKey=DBPassword,ParameterValue=Password \
                ParameterKey=SourceBucket,ParameterValue=$SourceBucket \
                ParameterKey=AppDomain,ParameterValue=uniqueddfdsfd1111
                

aws cloudformation wait stack-create-complete --stack-name edx-project-stack
AWS_ACCESS_KEY_ID=$(aws cloudformation describe-stacks --stack-name edx-project-stack \
--query 'Stacks[0].Outputs[?OutputKey==`AccessKey`].OutputValue' --output text)
AWS_SECRET_ACCESS_KEY=$(aws cloudformation describe-stacks --stack-name edx-project-stack \
--query 'Stacks[0].Outputs[?OutputKey==`SecretKey`].OutputValue' --output text)
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

pip install awscli --upgrade --user
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm
rm session-manager-plugin.rpm
