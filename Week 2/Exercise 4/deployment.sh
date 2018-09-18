export AWS_DEFAULT_REGION=us-east-1
SourceBucket=auniquesourcebucketname
cp ../../Week\ 1/Exercise\ 3/vpc.template .
aws s3api create-bucket --bucket $SourceBucket
aws s3 cp vpc.template s3://$SourceBucket
aws cloudformation create-stack --stack-name edx-project-stack --template-body file://cfn.yaml \
--capabilities CAPABILITY_NAMED_IAM \
--parameters ParameterKey=Password,ParameterValue=P@ssword ParameterKey=SourceBucket,ParameterValue=$SourceBucket 
aws cloudformation wait stack-create-complete --stack-name edx-project-stack
export AWS_ACCESS_KEY_ID=$(aws cloudformation describe-stacks --stack-name edx-project-stack \
--query 'Stacks[0].Outputs[?OutputKey==`AccessKey`].OutputValue' --output text)
export AWS_SECRET_ACCESS_KEY=$(aws cloudformation describe-stacks --stack-name edx-project-stack \
--query 'Stacks[0].Outputs[?OutputKey==`SecretKey`].OutputValue' --output text)