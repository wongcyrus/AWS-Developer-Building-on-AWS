export AWS_DEFAULT_REGION=us-east-1
AWSAccountId=$(aws sts get-caller-identity --query 'Account' --output text)
ImageBucket=imagebucket$AWSAccountId
aws s3 rm s3://$ImageBucket  --recursive
ImageBucket=imagebucketlambda$AWSAccountId
aws s3 rm s3://$ImageBucket  --recursive
aws cloudformation delete-stack --stack-name edx-project-stack