export AWS_DEFAULT_REGION=us-east-1
SourceBucket=auniquesourcebucketname
cp ../../Week\ 1/Exercise\ 3/vpc.template .
aws s3api create-bucket --bucket $SourceBucket
aws s3 cp vpc.template s3://$SourceBucket
rm vpc.template
aws cloudformation create-stack --stack-name edx-project-stack --template-body file://cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=Password,ParameterValue=P@ssword ParameterKey=SourceBucket,ParameterValue=$SourceBucket 
aws cloudformation wait stack-create-complete --stack-name edx-project-stack
AWS_ACCESS_KEY_ID=$(aws cloudformation describe-stacks --stack-name edx-project-stack \
--query 'Stacks[0].Outputs[?OutputKey==`AccessKey`].OutputValue' --output text)
AWS_SECRET_ACCESS_KEY=$(aws cloudformation describe-stacks --stack-name edx-project-stack \
--query 'Stacks[0].Outputs[?OutputKey==`SecretKey`].OutputValue' --output text)
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY