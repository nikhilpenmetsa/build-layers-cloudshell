# Lambda LangChain Layer

This project demonstrates how to create an AWS Lambda function that uses LangChain via a Lambda Layer.

## Project Structure

```
lambda-langchain-layer/
├── layer/
│   └── requirements.txt  # Dependencies for the layer
├── function/
│   └── lambda_function.py  # Lambda function code
├── template.yaml         # CloudFormation template
├── 2_deploy.bat          # Script to deploy the layer and function
├── 3_test.bat            # Script to test the function
└── 4_cleanup.bat         # Script to clean up resources
```

## Prerequisites

- AWS CLI installed and configured
- AWS CloudShell or Linux environment for building the layer
- PowerShell 5.0 or later for deployment scripts

## Instructions

### 1. Build the Layer in AWS CloudShell

The most reliable way to build the Lambda layer is using AWS CloudShell or another Linux environment:

1. **Open AWS CloudShell** in the AWS Management Console

2. **Create the necessary files and directories**:
   ```bash
   mkdir -p layer
   cd layer
   
   # Create requirements.txt
   cat > requirements.txt << 'EOF'
   langchain==0.0.267
   langchain-core==0.0.10
   langchain-community==0.0.10
   EOF
   ```

3. **Build the layer**:
   ```bash
   # Create a Python virtual environment
   python3.9 -m venv venv
   source venv/bin/activate
   
   # Upgrade pip
   pip install --upgrade pip
   
   # Create a directory for the layer
   mkdir -p python
   
   # Install dependencies directly to the layer directory
   pip install -r requirements.txt -t python/
   
   # Create the zip file with the correct structure
   zip -r langchain_layer.zip python/
   
   # Deactivate virtual environment
   deactivate
   ```

4. **Upload to S3**:
   ```bash
   # Create an S3 bucket if needed
   aws s3 mb s3://your-bucket-name
   
   # Upload the layer zip to S3
   aws s3 cp langchain_layer.zip s3://your-bucket-name/
   ```

5. **Download the layer to your local machine**:
   ```bash
   # Using AWS CLI on your local machine
   aws s3 cp s3://your-bucket-name/langchain_layer.zip .
   ```

### 2. Deploy the Layer and Function

After downloading the layer zip file to your local machine:

```
2_deploy.bat
```

This script will:
- Check if the layer zip file exists
- Create an S3 bucket for deployment
- Package the function code
- Upload both the layer and function to S3
- Deploy the CloudFormation stack

### 3. Test the Function

After deployment, test the function:

```
3_test.bat
```

### 4. Clean Up

When you're done, clean up all resources:

```
4_cleanup.bat
```

## Notes

- The example uses `FakeListLLM` for demonstration purposes
- In a real application, you would use a real LLM provider like OpenAI
- The Lambda function has a 30-second timeout, which may need adjustment for real LLM calls
- The layer is compatible with Python 3.9 runtime
- Building the layer in a Linux environment (like AWS CloudShell) ensures compatibility with Lambda's runtime environment