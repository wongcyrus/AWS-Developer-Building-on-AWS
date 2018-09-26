# Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except
# in compliance with the License. A copy of the License is located at
#
# https://aws.amazon.com/apache-2-0/
#
# or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
"Central configuration"

import requests
import os

r = requests.get("http://169.254.169.254/latest/dynamic/instance-identity/document")
response_json = r.json()
region = response_json.get('region')
os.environ['AWS_DEFAULT_REGION'] = region

def get_parameter():
    import boto3
    client = boto3.client('ssm',region_name=region)
    keys =['PHOTOS_BUCKET','FLASK_SECRET','DATABASE_HOST','DATABASE_USER', 'DATABASE_PASSWORD', 'DATABASE_DB_NAME', 'COGNITO_POOL_ID', 'COGNITO_CLIENT_ID', 'COGNITO_CLIENT_SECRET', 'COGNITO_DOMAIN', 'BASE_URL']
    ssm_keys = list(map(lambda k: "edx-" + k, keys))
    #it just supports 10 parameters each time!
    response1 = client.get_parameters(
        Names = ssm_keys[:10],
        WithDecryption = False
    )
    response2 = client.get_parameters(
        Names = ssm_keys[10:],
        WithDecryption = False
    )
    return dict(map(lambda x: (x['Name'].replace("edx-",""),x['Value']), response1["Parameters"] + response2["Parameters"]))
    
    
parameters = get_parameter()
    
PHOTOS_BUCKET = parameters['PHOTOS_BUCKET']
FLASK_SECRET = parameters['FLASK_SECRET']

DATABASE_HOST = parameters['DATABASE_HOST']
DATABASE_USER = parameters['DATABASE_USER']
DATABASE_PASSWORD = parameters['DATABASE_PASSWORD']
DATABASE_DB_NAME = parameters['DATABASE_DB_NAME']


AWS_REGION = region
COGNITO_POOL_ID = parameters['COGNITO_POOL_ID']
COGNITO_CLIENT_ID = parameters['COGNITO_CLIENT_ID']
COGNITO_CLIENT_SECRET = parameters['COGNITO_CLIENT_SECRET']
COGNITO_DOMAIN = parameters['COGNITO_DOMAIN']
BASE_URL = parameters['BASE_URL']

