import os
import tempfile
from PIL import Image
import tensorflow as tf
import io
import boto3
import base64
import numpy as np
import datetime
import json
from botocore.exceptions import ClientError


def analyze(model, image):
    try:
        # Convert RGBA to RGB if needed
        if image.mode == 'RGBA':
            image = image.convert('RGB')
            
        # Resize and normalize the image
        image = image.resize((224, 224))
        image = np.array(image, dtype=np.float32)  # Convert to NumPy and set type to float
        image_array = image / 255.0
        image_array = np.expand_dims(image_array, axis=0)

        # Perform predictions
        predictions = model.predict(image_array)

        # Extract the results
        result = predictions[0]

        # Find the index of the highest number in the results
        max_index = np.argmax(result)

        state = {
            0: 'Tomato Bacterial spot',
            1: 'Tomato Early blight',
            2: 'Tomato healthy',
            3: 'Tomato Late blight',
            4: 'Tomato Leaf Mold',
            5: 'Tomato mosaic virus',
            6: 'Tomato Septoria leaf spot',
            7: 'Tomato Spider mites',
            8: 'Tomato Target Spot',
            9: 'Tomato Yellow Leaf Curl Virus'
        }

        return state, result, max_index

    except ClientError as e:
        print(f"An error occurred: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'An error occurred while analyzing the image.'}),
            'headers': {
                'Content-Type': 'application/json'
            }
        }

def lambda_handler(event, context):
    try:
        # S3 initializations
        s3Client = boto3.client("s3")
        s3Resource = boto3.resource("s3")

        # Get model
        content_object = s3Resource.Object('olaf-s3', 'model/CropAI.keras')
        model_object = content_object.get()['Body'].read()
        temp_model_file_path = None

        with tempfile.NamedTemporaryFile(suffix='.keras', delete=False) as temp_model_file:
            temp_model_file_path = temp_model_file.name
            temp_model_file.write(model_object)
            temp_model_file.flush()  # Ensure data is written to disk
            model = tf.keras.models.load_model(temp_model_file.name)

        imageBase64 = event.get('image')
        image_bytes = base64.b64decode(imageBase64)
        image = Image.open(io.BytesIO(image_bytes))
        result = analyze(model, image)

        userId = event.get('userId')

        data = {
            "image": imageBase64,
            "result": result
        }
        json_data = json.dumps(data)
        json_encoded = json_data.encode('utf-8')

        current_datetime = datetime.datetime.now()

        formatted_datetime = current_datetime.strftime("%Y-%m-%d %H:%M:%S")

        s3Client.put_object(
            Bucket="olaf-s3",
            Key=f'users/{userId}/analyzed/{formatted_datetime}.json',
            Body=json_encoded,
        )
    except ClientError as e:
        print(f"An error occurred: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'An error occurred while retrieving the model.'}),
            'headers': {
                'Content-Type': 'application/json'
            }
        }
    if temp_model_file_path and os.path.isfile(temp_model_file_path):
        os.remove(temp_model_file_path)
    return {
        'statusCode': 200,
        'body': json.dumps({'message': result}),
        'headers': {
            'Content-Type': 'application/json'
        }
    }
