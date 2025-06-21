# SPDX-FileCopyrightText: 2021 ladyada for Adafruit Industries
# SPDX-License-Identifier: MIT

import time
import board
import adafruit_dht
import RPi.GPIO as GPIO
from picamera2 import Picamera2 
import traceback
import busio
import adafruit_ads1x15.ads1015 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
import json
import base64
import os
import requests

# Setup GPIO
GPIO.setmode(GPIO.BCM)

# Initialize the DHT22 sensor
dhtDevice = adafruit_dht.DHT22(board.D18)

# Initialize I2C bus using SCL and SDA pins
i2c = busio.I2C(board.SCL, board.SDA)
moisture_channel=None
# Create the ADC object using the I2C bus
try:
    ads = ADS.ADS1015(i2c)
    moisture_channel = AnalogIn(ads, ADS.P0)
except Exception as e:
    pass

def read_moisture():
    """Read soil moisture from I2C ADC connected to SCL and SDA pins"""
    try:
        # Get raw ADC value
        raw_value = moisture_channel.value

        raw_dry = 28000    # value when dry
        raw_wet = 10000    # value when wet

        moisture_percent = 100 * (raw_dry - raw_value) / (raw_dry - raw_wet)
        moisture_percent = max(0, min(100, moisture_percent))  # Clamp between 0 and 100

        # Limit to 3 decimal places
        moisture_percent = round(moisture_percent, 2)

        return moisture_percent
    except Exception as e:
        return 0

def read_user_info():
    user_info_path = "./user_info.json"
    try:
        with open(user_info_path, "r") as f:
            content = f.read()
            return json.loads(content)
    except Exception:
        return {}

# Read soilHumidityRange from file or set default
soil_humidity_range_file = "soilHumidityRange.json"
default_soil_humidity_range = [50, 80]
soilHumidityRange = default_soil_humidity_range
if os.path.exists(soil_humidity_range_file):
    try:
        with open(soil_humidity_range_file, "r") as f:
            soilHumidityRange = json.load(f)
    except Exception:
        soilHumidityRange = default_soil_humidity_range

try:
    user_info = read_user_info()
    email = user_info.get("email", "")
    plant_name = user_info.get("plant_name", "")
    pot_name = user_info.get("pot_name", "")
    while True:
        loop_start = time.time()
        try:
            # Read temperature and humidity
            temperature_c = dhtDevice.temperature
            if temperature_c is None:
                temperature_c = 0
            humidity = dhtDevice.humidity
            if humidity is None:
                humidity = 0
            # Read soil moisture
            moisture = read_moisture()
        except RuntimeError as error:
            time.sleep(2.0)
            continue
        except Exception as error:
            dhtDevice.exit()
            GPIO.cleanup()  # Clean up GPIO on exit
            raise error

        # Take a picture with the OKdo 5MP camera
        image_base64 = None
        try:
            picam2 = Picamera2()
            picam2.start()
            image_path = "plant_picture.jpg"
            picam2.capture_file(image_path)
            picam2.close()
            with open(image_path, "rb") as img_file:
                image_base64 = base64.b64encode(img_file.read()).decode('utf-8')
            os.remove(image_path)
        except Exception as e:
            image_base64 = None

        output_data = {
            "email": email if email else "unknown",
            "plant_name": plant_name if plant_name else "unknown",
            "pot_name": pot_name if pot_name else "unknown",
            "temperature_c": temperature_c if temperature_c is not None else 0,
            "humidity": humidity if humidity is not None else 0,
            "soil_moisture": moisture if moisture is not None else 0,
            "image_base64": image_base64 if image_base64 else "",
            "soilHumidityRange": soilHumidityRange
        }
        with open("output.json", "w") as f:
            json.dump(output_data, f)
        # Send JSON to AWS Lambda
        try:
            lambda_url = "https://ebaopnsvzapbk5eqbnc2iw7b6e0pljsh.lambda-url.eu-west-3.on.aws/"
            headers = {"Content-Type": "application/json"}
            response = requests.post(lambda_url, json=output_data, headers=headers)
            print(f"Lambda response: {response.status_code} - {response.text}")
            # Parse and save soilHumidityRange from Lambda response
            if response.status_code == 200:
                try:
                    resp_json = response.json()
                    if "body" in resp_json:
                        body = json.loads(resp_json["body"])
                        if "soilHumidityRange" in body:
                            soilHumidityRange = body["soilHumidityRange"]
                            with open(soil_humidity_range_file, "w") as f:
                                json.dump(soilHumidityRange, f)
                except Exception as e:
                    print(f"Failed to parse or save soilHumidityRange: {e}")
        except Exception as e:
            print(f"Failed to send data to Lambda: {e}")

        # Ensure exactly 15 seconds between requests
        elapsed = time.time() - loop_start
        if elapsed < 15:
            time.sleep(15 - elapsed)
except:
    GPIO.cleanup()