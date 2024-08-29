import json
import hashlib
from botocore.exceptions import ClientError
import boto3



def hash(s3_object):
    hash_algo = hashlib.sha256()

    # Read the file in chunks to avoid memory issues
    with s3_object.get()['Body'] as body:
        while chunk := body.read(8192):
            hash_algo.update(chunk)

    return hash_algo.hexdigest()


def compareModels(oldModel, newModel):
    hash1 = hash(oldModel)
    hash2 = hash(newModel)

    return hash1 == hash2


def lambda_handler(event, context):
    s3 = boto3.resource("s3")
    s3Client = boto3.client("s3")

    oldExist = False
    try:
        oldModel = s3.Object('olaf-s3', 'model/CropAI.keras')
        oldModel_content = oldModel.get()['Body']
        oldExist = True
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code != 'AccessDenied':
            return {
                'statusCode': 400,
                'body': e
            }

    try:
        # Load CropAI.keras from olaf-s3's update folder 
        newModel = s3.Object('olaf-s3', 'update/CropAI.keras')
        newModel_content = newModel.get()['Body'].read()
        if (oldExist):
            if (compareModels(oldModel, newModel) == False):
                s3Client.put_object(
                    Bucket="olaf-s3",
                    Key='model/CropAI.keras',
                    Body=newModel_content
                )
                statusCode = 200
                body = "File updated successfully"
            else:
                statusCode = 200
                body = "Identical version"
        else:
            s3Client.put_object(
                Bucket="olaf-s3",
                Key='model/CropAI.keras',
                Body=newModel_content
            )
            statusCode = 200
            body = "File updated successfully"

        s3.Object('olaf-s3', 'update/CropAI.keras').delete()
        return {
            'statusCode': statusCode,
            'body': body
        }
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'AccessDenied':
            return {
                'statusCode': 404,
                'body': f"File CropAI.keras does not exist in bucket olaf-s3, folder update."
            }
        else:
            print(f"An error occurred: {e}")
