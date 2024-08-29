import json
import boto3
import hashlib
from botocore.exceptions import ClientError
# Setup the table
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table("olaf-lexica")

# Get item based on the name and the version number


def getItem(name):
    response = table.query(
        KeyConditionExpression=boto3.dynamodb.conditions.Key('name').eq(name),
        ScanIndexForward=False,
        Limit=1  # Get only the highest version
    )
    # Check if any item is returned
    if response['Items']:
        return response['Items'][0]
    else:
        return None
    
# This function hashes items to be able to compare a new item from the previous one

def convert_sets(obj):
    if isinstance(obj, set):
        return list(obj)
    if isinstance(obj, dict):
        return {k: convert_sets(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [convert_sets(i) for i in obj]
    return obj
        
def hash_item(details):
    details = convert_sets(details)
    return hashlib.sha256(json.dumps(details, sort_keys=True).encode('utf-8')).hexdigest()

# Push a plant into the lexica


def pushPlant(newPlant):
    item = getItem(newPlant['name'])

    newItem = {
        'name': newPlant['name'],
        'version': item.get('version', 0) + 1 if item else 0,
        'details': {
            "diseases": [
                {
                    "name": disease['name'],
                    "image": disease['image']
                }
                for disease in newPlant['diseases']
            ],
            "howTo": newPlant['howTo'],  # Use directly as a string
            "image": newPlant['image'],  # Use directly as a string
            # This should be a list, so leave as is
            "tips": newPlant['tips']
        }
    }

    if item is None or hash_item(item['details']) != hash_item(newItem['details']):
        table.put_item(Item=newItem)


# Push a disease into the lexica
def pushDisease(newDisease):
    print(newDisease)
    item = getItem(newDisease['name'])

    newItem = {
        'name': newDisease['name'],
        'version': item.get('version', 0) + 1 if item else 0,
        'details': {
            "cure": newDisease['cure'],
            "description": newDisease['description'],
            "icon": newDisease['icon'],
            'image': newDisease['image'],
            'prevent': newDisease['prevent']
        }
    }

    if item is None or hash_item(item['details']) != hash_item(newItem['details']):
        table.put_item(Item=newItem)


def lambda_handler(context, event):

    # If update.json does not exist, return end the process
    try:
        # Load lexica.json from the olaf-s3's update folder
        s3 = boto3.resource("s3")
        content_object = s3.Object('olaf-s3', 'update/lexica.json')
        file_content = content_object.get()['Body'].read().decode('utf-8')
        json_content = json.loads(file_content)
    except ClientError as e:
        error_code = e.response['Error']['Code']
        if error_code == 'AccessDenied':
           return {
            'statusCode': 404,
            'body': "File lexica.json does not exist in bucket olaf-s3, folder update."
            }
        else:
            print(f"An error occurred: {e}")

    if 'plants' in json_content:
        for plant, plant_details in json_content['plants'].items():
            pushDisease(plant_details)
    if 'diseases' in json_content:
        for disease_name, disease_details in json_content['diseases'].items():
            pushDisease(disease_details)
    s3.Object('olaf-s3', 'update/lexica.json').delete()

    return {
            'statusCode': 200,
            'body': "Lexica updated successfully " 
        }
