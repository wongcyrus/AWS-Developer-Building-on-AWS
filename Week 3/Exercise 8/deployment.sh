export AWS_DEFAULT_REGION=us-east-1
AWSAccountId=$(aws sts get-caller-identity --query 'Account' --output text)
SourceBucket=sourcebucket$AWSAccountId

aws s3api create-bucket --bucket $SourceBucket
sleep 5

wget https://s3-us-west-2.amazonaws.com/us-west-2-tcdev/courses/AWS-100-ADG/v1.1.0/exercises/ex-rds.zip
unzip -o ex-rds.zip
rm ex-rds.zip
yes | cp -f code/app.ini exercise-rds/Deploy/
yes | cp -f code/config.py exercise-rds/FlaskApp/
yes | cp -f code/requirements.txt exercise-rds/FlaskApp/
cd exercise-rds
zip -ro deploy-app.zip Deploy/ FlaskApp/
aws s3 cp deploy-app.zip s3://$SourceBucket/
cd ..
rm -rf exercise-rds

cp ../../Week\ 1/Exercise\ 3/vpc.yaml .
cp ../../Week\ 2/Exercise\ 5/iam.yaml .
aws s3 sync . s3://$SourceBucket 
rm vpc.yaml
rm iam.yaml


# aws cloudformation create-stack --stack-name edx-project-stack --template-body file://cfn.yaml \
aws cloudformation update-stack --stack-name edx-project-stack \
--template-url https://s3.amazonaws.com/$SourceBucket/cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters    ParameterKey=Password,ParameterValue=P@ssword \
                ParameterKey=DBPassword,ParameterValue=Password \
                ParameterKey=SourceBucket,ParameterValue=$SourceBucket
                
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
