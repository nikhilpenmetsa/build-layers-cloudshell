import json
import os
import sys

def lambda_handler(event, context):
    """
    Lambda function that uses LangChain to process input text.
    """
    # Get input from the event
    input_text = event.get('input', 'Hello, world!')
    
    try:
        # Import specific modules directly
        import langchain
        from langchain.llms.fake import FakeListLLM
        from langchain.prompts import PromptTemplate
        from langchain.chains import LLMChain
        
        # Print versions for debugging
        print(f"LangChain version: {langchain.__version__}")
        
        # Create a simple prompt template
        prompt = PromptTemplate(
            input_variables=["input"],
            template="Echo back: {input}"
        )
        
        # Use FakeListLLM for demonstration
        responses = [f"Processed: {input_text}"]
        llm = FakeListLLM(responses=responses)
        
        # Create and run the chain
        chain = LLMChain(llm=llm, prompt=prompt)
        result = chain.run(input=input_text)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'input': input_text,
                'output': result
            })
        }
    except Exception as e:
        import traceback
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'traceback': traceback.format_exc(),
                'input': input_text
            })
        }