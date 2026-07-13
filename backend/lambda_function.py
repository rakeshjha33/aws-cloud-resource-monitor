import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

TABLE_NAME = 'AWSResourceTracking'
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN') # Set this in Lambda Env Variables
EC2_THRESHOLD = 5 # Alert if active running instances exceed this number

def lambda_handler(event, context):
    try:
        # 1. Parse incoming data from API Gateway
        body = json.loads(event['body'])
        
        # 2. Add fixed ID key for single-item snapshot pattern
        body['id'] = 'latest'
        
        # 3. Save to DynamoDB
        table = dynamodb.Table(TABLE_NAME)
        table.put_item(Item=body)
        
        # 4. Threshold & Alerting Logic
        # Flatten the arrays to count active instances accurately
        ec2_instances = body.get('ec2', [])
        # Check running instances count depending on nesting structure of response
        running_count = sum(1 for res in ec2_instances for inst in res if inst.get('State') == 'running')
        
        if running_count > EC2_THRESHOLD:
            alert_message = f"ALERT: High resource utilization detected!\n\nRunning EC2 Instances: {running_count} (Threshold: {EC2_THRESHOLD}).\nTimestamp: {body['timestamp']}"
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=alert_message,
                Subject="⚠️ AWS Real-Time Resource Alert"
            )
        
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*', # Enables CORS for frontend
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({'message': 'Data processed and saved successfully!'})
        }
        
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
