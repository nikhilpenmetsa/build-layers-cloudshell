@echo off
echo Cleaning up resources...

REM Configuration
set STACK_NAME=langchain-demo-stack

REM Get the S3 bucket name from the stack
for /f "tokens=*" %%a in ('aws cloudformation describe-stacks --stack-name %STACK_NAME% --query "Stacks[0].Parameters[?ParameterKey==''LayerBucket''].ParameterValue" --output text') do set S3_BUCKET_NAME=%%a

REM Delete the CloudFormation stack
echo Deleting CloudFormation stack: %STACK_NAME%
aws cloudformation delete-stack --stack-name %STACK_NAME%

REM Wait for stack deletion to complete
echo Waiting for stack deletion to complete...
aws cloudformation wait stack-delete-complete --stack-name %STACK_NAME%

REM Empty and delete the S3 bucket if it exists
if not "%S3_BUCKET_NAME%"=="" (
    echo Emptying S3 bucket: %S3_BUCKET_NAME%
    aws s3 rm s3://%S3_BUCKET_NAME% --recursive
    
    echo Deleting S3 bucket: %S3_BUCKET_NAME%
    aws s3 rb s3://%S3_BUCKET_NAME%
)

echo Cleanup complete!