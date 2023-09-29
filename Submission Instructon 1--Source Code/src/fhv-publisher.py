import requests
import boto3
import json
import os
from datetime import datetime, timedelta

# AWS Lambda handler function
def fhv_lambda_handler(event, context):
    #S3 config details bucket name like "onelake-dev-ue1" and prefix as "fhv-data"
    s3_bucket_name=os.environ["s3_bucket_name"]
    s3_prefix =os.environ["s3_prefix"]
    # NYC FHV API URL eg:'https://data.cityofnewyork.us/resource/8wbx-tsch.json?last_date_updated='
    api=os.environ["api"]
    # Get the current datetime
    current_datetime = datetime.now()
    try:
        api_url=api+current_datetime.strftime("%Y-%m-%d")
        # Fetch data from NYC API using filter last_date_updated with current date
        response = requests.get(api_url)
        if response.status_code == 200:
            data = response.json()
            
            # Generate a unique key for each data snapshot
            s3_key= "{}/year={}/month={}/day={}/{}".format(s3_prefix,current_datetime.strftime("%Y"),current_datetime.strftime("%m"),current_datetime.strftime("%d"),"fhv_data.json")
            
            # Upload data to S3
            s3_client = boto3.client('s3')
            s3_client.put_object(
                Bucket=s3_bucket_name,
                Key=s3_key,
                Body=json.dumps(data),
                ContentType='application/json'
            )
            return {
                'statusCode': 200,
                'body': 'Data ingestion successful'
            }
        else:
            return {
                'statusCode': response.status_code,
                'body': 'Failed to fetch data from NYC API'
            }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': str(e)
        }
