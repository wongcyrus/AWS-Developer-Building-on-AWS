export AWS_DEFAULT_REGION=us-east-1
AWSAccountId=$(aws sts get-caller-identity --query 'Account' --output text)
SourceBucket=sourcebucket$AWSAccountId

cp ../../Week\ 1/Exercise\ 3/vpc.yaml .
cp ../../Week\ 2/Exercise\ 5/iam.yaml .
cp ../../Week\ 4/Exercise\ 9/cdn.yaml .
cp ../../Week\ 4/Exercise\ 9/cloud9.yaml .
cp ../../Week\ 4/Exercise\ 9/cognito.yaml .
cp ../../Week\ 4/Exercise\ 9/db.yaml .
cp ../../Week\ 4/Exercise\ 9/parameters.yaml .
cp ../../Week\ 5/Exercise\ 10/web.yaml .
aws s3 sync . s3://$SourceBucket 
rm vpc.yaml
rm iam.yaml
rm cdn.yaml
rm cloud9.yaml
rm cognito.yaml
rm db.yaml
rm parameters.yaml
rm web.yaml

wget https://us-west-2-tcdev.s3.amazonaws.com/courses/AWS-100-ADG/v1.1.0/exercises/ex-lambda.zip
unzip -o ex-lambda.zip
rm ex-lambda.zip
yes | cp -f ../../Week\ 4/Exercise\ 9/code/config.py exercise-lambda/FlaskApp/
yes | cp -f ../../Week\ 3/Exercise\ 8/code/database_create_tables.py exercise-lambda/Deploy/
yes | cp -f ../../Week\ 4/Exercise\ 9/code/nginx.conf exercise-lambda/Deploy/
yes | cp -f ../../Week\ 4/Polly/code/app.ini exercise-lambda/Deploy/
cd exercise-lambda
zip -ro deploy-app.zip Deploy/ FlaskApp/
aws s3 cp deploy-app.zip s3://$SourceBucket/
cd ..
rm -rf exercise-lambda

aws cloudformation update-stack --stack-name edx-project-stack \
--template-url https://s3.amazonaws.com/$SourceBucket/cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters    ParameterKey=Password,UsePreviousValue=true \
                ParameterKey=DBPassword,UsePreviousValue=true \
                ParameterKey=SourceBucket,UsePreviousValue=true \
                ParameterKey=AppDomain,UsePreviousValue=true
                
aws cloudformation wait stack-update-complete --stack-name edx-project-stack


