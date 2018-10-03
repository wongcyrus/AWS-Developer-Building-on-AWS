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
"Long polling the SQS queue for image uploads"
import sys
import json
import boto3

# Create SQS client
sqs = boto3.client('sqs')


if len(sys.argv) < 2:
    print("Usage: pass the SQS queue url as the first parameter")
    sys.exit(0)

queue_url = sys.argv[1]

print("Polling the photos queue.  Ctrl-C to exit.")

# Long poll for message on provided SQS queue
while True:
    response = sqs.receive_message(
        QueueUrl=queue_url,
        WaitTimeSeconds=20
    )
    if 'Messages' in response:
        receipt_handle = response['Messages'][0]["ReceiptHandle"]
        body = json.loads(response['Messages'][0]["Body"])
        message = json.loads(body["Message"])
        if "Records" in message:
            s3_bucket = message["Records"][0]["s3"]["bucket"]["name"]
            s3_object_key = message["Records"][0]["s3"]["object"]["key"]
            s3_object_size = message["Records"][0]["s3"]["object"]["size"]
            print("We have a new upload: bucket: %s key: %s, size: %s bytes" %
                  (s3_bucket, s3_object_key, s3_object_size))
        else:
            print("Not the message we were expecting")
            print(message)

        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
