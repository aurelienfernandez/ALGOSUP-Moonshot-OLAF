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

        
        return moisture_percent
    except Exception as e:
        return 0

def read_user_info():
    user_info_path = "./user_info.json"
    print(f"Reading user info from: {user_info_path}")
    
    try:
        with open(user_info_path, "r") as f:
            print("User info file found, reading data.")
            print(f"User info content: {f.read()}")
            return json.load(f)
    except Exception:
        return {}

try:
    user_info = read_user_info()
    email = user_info.get("email", "")
    plant_name = user_info.get("plant_name", "")
    pot_name = user_info.get("pot_name", "")
    while True:
        try:
            # Read temperature and humidity
            temperature_c = dhtDevice.temperature
            humidity = dhtDevice.humidity
            
            # Read soil moisture
            moisture = read_moisture()
            moisture_outuput="<50%"
            if(moisture ==1):
                moisture_outuput=">50%"
            else:
                moisture_outuput="<50%"
                
        except RuntimeError as error:
            time.sleep(2.0)
            continue
        except Exception as error:
            dhtDevice.exit()
            GPIO.cleanup()  # Clean up GPIO on exit
            raise error

        time.sleep(2.0)
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
            "email": email,
            "plant_name": plant_name,
            "pot_name": pot_name,
            "temperature_c": temperature_c,
            "humidity": humidity,
            "soil_moisture": moisture,
            "image_base64": image_base64
        }
        with open("output.json", "w") as f:
            json.dump(output_data, f)
except:
    GPIO.cleanup()