@echo off
echo Testing Lambda function...

REM Configuration
set FUNCTION_NAME=langchain-demo-function

REM Create a test event payload
echo Creating test event payload...
echo {> test_event.json
echo   "input": "This is a test input for LangChain">> test_event.json
echo }>> test_event.json

REM Invoke the Lambda function
echo Invoking Lambda function...
aws lambda invoke ^
    --function-name %FUNCTION_NAME% ^
    --payload fileb://test_event.json ^
    --cli-binary-format raw-in-base64-out ^
    response.json

REM Display the response
echo Lambda function response:
type response.json

REM Clean up
echo Cleaning up test files...
del test_event.json
del response.json

echo Test complete!