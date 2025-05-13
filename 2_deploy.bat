@echo off
echo Deploying Lambda function with LangChain layer...

REM Configuration
set STACK_NAME=langchain-demo-stack
set FUNCTION_NAME=langchain-demo-function
set LAYER_NAME=langchain-layer
set LAYER_ZIP=langchain_layer.zip
set FUNCTION_ZIP=function.zip

REM Check if layer zip exists
if not exist %LAYER_ZIP% (
    echo ERROR: Layer zip file %LAYER_ZIP% not found.
    echo Please run 1_build_layer.bat first to build the layer.
    exit /b 1
)

REM Get AWS account ID for S3 bucket name
for /f "tokens=*" %%a in ('aws sts get-caller-identity --query Account --output text') do set AWS_ACCOUNT=%%a
set S3_BUCKET_NAME=langchain-layer-%AWS_ACCOUNT%-%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set S3_BUCKET_NAME=%S3_BUCKET_NAME: =%

REM Get AWS region
for /f "tokens=*" %%a in ('aws configure get region') do set REGION=%%a
if "%REGION%"=="" (
    set REGION=us-east-1
    echo AWS region not configured, defaulting to %REGION%
)

REM Check if the stack exists and delete it if it does
echo Checking if stack exists...
aws cloudformation describe-stacks --stack-name %STACK_NAME% >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Stack exists, deleting it first...
    aws cloudformation delete-stack --stack-name %STACK_NAME%
    echo Waiting for stack deletion to complete...
    aws cloudformation wait stack-delete-complete --stack-name %STACK_NAME%
    echo Stack deletion complete.
) else (
    echo Stack does not exist or is already deleted.
)

echo Creating S3 bucket for deployment...
aws s3 mb s3://%S3_BUCKET_NAME% --region %REGION% || echo Bucket may already exist or name is taken, continuing...

REM Package the function code
echo Packaging function code...
cd function
powershell Compress-Archive -Path * -DestinationPath ..\%FUNCTION_ZIP% -Force
cd ..

REM Upload the layer and function to S3
echo Uploading layer and function to S3...
aws s3 cp %LAYER_ZIP% s3://%S3_BUCKET_NAME%/%LAYER_ZIP%
aws s3 cp %FUNCTION_ZIP% s3://%S3_BUCKET_NAME%/%FUNCTION_ZIP%

REM Deploy the CloudFormation stack
echo Deploying CloudFormation stack...
aws cloudformation deploy ^
    --template-file template.yaml ^
    --stack-name %STACK_NAME% ^
    --parameter-overrides ^
        FunctionName=%FUNCTION_NAME% ^
        LayerName=%LAYER_NAME% ^
        LayerBucket=%S3_BUCKET_NAME% ^
        LayerKey=%LAYER_ZIP% ^
        FunctionBucket=%S3_BUCKET_NAME% ^
        FunctionKey=%FUNCTION_ZIP% ^
    --capabilities CAPABILITY_IAM

REM Clean up
echo Cleaning up build artifacts...
del %FUNCTION_ZIP%

echo Deployment complete!
echo Stack name: %STACK_NAME%
echo Function name: %FUNCTION_NAME%
echo Layer name: %LAYER_NAME%
echo S3 bucket: %S3_BUCKET_NAME%