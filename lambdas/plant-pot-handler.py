import json
import boto3
from botocore.exceptions import ClientError

def translate_plant_name(french_name):
    """
    Translate plant name from French to English using a local map
    Input is converted to lowercase for case-insensitive matching
    Output is capitalized
    """
    # Comprehensive French to English plant name mapping
    plant_translations = {
        # Vegetables
        "pomme de terre": "potato",
        "patate": "potato",
        "tomate": "tomato",
        "carotte": "carrot",
        "oignon": "onion",
        "ail": "garlic",
        "poireau": "leek",
        "courgette": "zucchini",
        "aubergine": "eggplant",
        "concombre": "cucumber",
        "poivron": "bell pepper",
        "piment": "chili pepper",
        "chou": "cabbage",
        "chou-fleur": "cauliflower",
        "brocoli": "broccoli",
        "épinard": "spinach",
        "laitue": "lettuce",
        "salade": "lettuce",
        "mais": "corn",
        "maïs": "corn",
        "haricot": "bean",
        "haricot vert": "green bean",
        "petit pois": "pea",
        "pois": "pea",
        "potiron": "pumpkin",
        "citrouille": "pumpkin",
        "courge": "squash",
        "betterave": "beetroot",
        "radis": "radish",
        "artichaut": "artichoke",
        "asperge": "asparagus",
        "champignon": "mushroom",
        "endive": "endive",
        "fenouil": "fennel",
        "céleri": "celery",
        
        # Fruits
        "pomme": "apple",
        "poire": "pear",
        "orange": "orange",
        "citron": "lemon",
        "pamplemousse": "grapefruit",
        "banane": "banana",
        "fraise": "strawberry",
        "framboise": "raspberry",
        "myrtille": "blueberry",
        "mûre": "blackberry",
        "groseille": "currant",
        "raisin": "grape",
        "cerise": "cherry",
        "abricot": "apricot",
        "pêche": "peach",
        "nectarine": "nectarine",
        "prune": "plum",
        "melon": "melon",
        "pastèque": "watermelon",
        "figue": "fig",
        "kiwi": "kiwi",
        "mangue": "mango",
        "ananas": "pineapple",
        "avocat": "avocado",
        "grenade": "pomegranate",
        "datte": "date",
        "noix de coco": "coconut",
        
        # Herbs and spices
        "basilic": "basil",
        "persil": "parsley",
        "coriandre": "coriander",
        "menthe": "mint",
        "thym": "thyme",
        "romarin": "rosemary",
        "sauge": "sage",
        "ciboulette": "chives",
        "aneth": "dill",
        "estragon": "tarragon",
        "origan": "oregano",
        "laurier": "bay leaf",
        
        # Flowers and ornamental plants
        "rose": "rose",
        "tulipe": "tulip",
        "marguerite": "daisy",
        "tournesol": "sunflower",
        "lilas": "lilac",
        "orchidée": "orchid",
        "cactus": "cactus",
        "fougère": "fern",
        "lavande": "lavender",
        "lys": "lily",
        "jasmin": "jasmine",
        "dahlia": "dahlia",
        "hortensia": "hydrangea",
        "géranium": "geranium",
        "amaryllis": "amaryllis",
        "violette": "violet",
        "pivoine": "peony",
        "chrysanthème": "chrysanthemum",
        "bégonia": "begonia",
        "azalée": "azalea",       
    }
    
    # Convert input to lowercase for case-insensitive matching
    french_name_lower = french_name.lower() if french_name else ""
    
    # Look up translation
    english_name = plant_translations.get(french_name_lower)
    
    # If found, capitalize and return; else, return the original name capitalized
    if english_name:
        return english_name.capitalize()
    else:
        return french_name.capitalize() if french_name else ""

def lambda_handler(event, context):
    try:
        # Parse the incoming JSON payload
        payload = json.loads(event['body']) if 'body' in event else event

        # Extract data from the payload (expecting the new structure)
        email = payload.get('email')
        plant_name = payload.get('plant_name')
        pot_name = payload.get('pot_name')
        temperature_c = payload.get('temperature_c')
        humidity = payload.get('humidity')
        moisture = payload.get('soil_moisture')
        image_base64 = payload.get('image_base64')
        # Validate required fields
        if (
            not email or
            not plant_name or
            not pot_name or
            temperature_c is None or
            humidity is None or
            moisture is None or
            image_base64 is None
        ):
            # Find which fields are missing
            missing_fields = []
            if not email:
                missing_fields.append("email")
            if not plant_name:
                missing_fields.append("plant_name")
            if not pot_name:
                missing_fields.append("pot_name")
            if temperature_c is None:
                missing_fields.append("temperature_c")
            if humidity is None:
                missing_fields.append("humidity")
            if moisture is None:
                missing_fields.append("soil_moisture")
            if image_base64 is None:
                missing_fields.append("image_base64")
            return {
                'statusCode': 400,
                'body': json.dumps({"message": "Missing field(s):", "fields": missing_fields})
            }

        # Translate plant name from French to English
        plant_name_en = translate_plant_name(plant_name)

        # Find the user in Cognito
        cognito_client = boto3.client('cognito-idp')
        user_id = find_user_by_email(cognito_client, email)

        if not user_id:
            return {
                'statusCode': 404,
                'body': json.dumps(f'User not found with email: {email}')
            }

        # Prepare the data to save (overwrite plant_name with English translation)
        # Save or update the data in S3 as a list of pots
        s3_client = boto3.client('s3')
        bucket_name = 'olaf-s3'
        file_key = f'users/{user_id}/plant-pots.json'

        # Try to load existing pots
        try:
            response = s3_client.get_object(Bucket=bucket_name, Key=file_key)
            pots_data = json.loads(response['Body'].read().decode('utf-8'))
            if not isinstance(pots_data, dict) or 'pots' not in pots_data or not isinstance(pots_data['pots'], list):
                pots_data = {"pots": []}
        except ClientError as e:
            if e.response['Error']['Code'] == 'NoSuchKey':
                pots_data = {"pots": []}
            else:
                raise

        # Check if the pot already exists (by plant_name and pot_name)
        pot_found = None
        for pot in pots_data['pots']:
            if pot.get('plant_name') == plant_name_en and pot.get('pot_name') == pot_name:
                pot_found = pot
                break

        def update_list(old_list, new_value):
            # Ensure list is length 8, append new_value, drop oldest if needed
            if not isinstance(old_list, list):
                old_list = []
            old_list.append(new_value)
            while len(old_list) < 8:
                old_list.insert(0, 0)
            if len(old_list) > 8:
                old_list = old_list[-8:]
            return old_list

        if pot_found:
            # Update existing pot's lists
            pot_found['temperature_c'] = update_list(pot_found.get('temperature_c', []), temperature_c)
            pot_found['humidity'] = update_list(pot_found.get('humidity', []), humidity)
            pot_found['soil_moisture'] = update_list(pot_found.get('soil_moisture', []), moisture)
            pot_found['image_base64'] = image_base64  # Always update image
        else:
            # Create new pot with lists initialized
            new_pot = {
                "plant_name": plant_name_en,
                "pot_name": pot_name,
                "temperature_c": update_list([], temperature_c),
                "humidity": update_list([], humidity),
                "soil_moisture": update_list([], moisture),
                "image_base64": image_base64
            }
            pots_data['pots'].append(new_pot)

        # Save back to S3
        s3_client.put_object(
            Bucket=bucket_name,
            Key=file_key,
            Body=json.dumps(pots_data),
            ContentType='application/json'
        )

        # Optionally, get plant details from DynamoDB
        plant_details = get_plant_from_dynamodb(plant_name_en)

        response_body = {
            'message': 'Plant pot data saved successfully'
        }

        if plant_details and 'details' in plant_details and 'soilHumidityRange' in plant_details['details']:
            response_body['details'] = {
                'soilHumidityRange': plant_details['details']['soilHumidityRange']
            }

        return {
            'statusCode': 200,
            'body': json.dumps(response_body)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error processing request: {str(e)}')
        }

def get_plant_from_dynamodb(plant_name):
    """
    Get plant details from DynamoDB by plant name
    """
    try:
        dynamodb = boto3.client('dynamodb')
        response = dynamodb.get_item(
            TableName='olaf-lexica',
            Key={
                'name': {'S': plant_name}
            }
        )
        
        # Check if item exists
        if 'Item' in response:
            # Convert DynamoDB format to standard Python dict
            plant_data = {}
            plant_data['name'] = response['Item']['name']['S']
            
            if 'details' in response['Item']:
                plant_data['details'] = {}
                details_map = response['Item']['details']['M']
                
                if 'soilHumidityRange' in details_map:
                    plant_data['details']['soilHumidityRange'] = [
                        int(item['N']) for item in details_map['soilHumidityRange']['L']
                    ]
            
            return plant_data
        return None
    except ClientError as e:
        print(f"Error querying DynamoDB: {str(e)}")
        return None

def find_user_by_email(cognito_client, email):
    """
    Find a user in Cognito by email and return their user ID
    """
    try:
        response = cognito_client.list_users(
            UserPoolId='eu-west-3_WrZOfvyGN',  
            Filter=f'email="{email}"'
        )
        
        users = response.get('Users', [])
        if users:
            # Return the user's sub attribute (UUID)
            for attribute in users[0]['Attributes']:
                if attribute['Name'] == 'sub':
                    return attribute['Value']
        
        return None
    except ClientError as e:
        print(f"Error finding user: {str(e)}")
        return None
