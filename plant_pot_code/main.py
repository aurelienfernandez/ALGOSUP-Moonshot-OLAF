# SPDX-FileCopyrightText: 2021 ladyada for Adafruit Industries
# SPDX-License-Identifier: MIT

import time
import board
import adafruit_dht
import RPi.GPIO as GPIO

# Setup GPIO for moisture sensor
GPIO.setmode(GPIO.BCM)
MOISTURE_PIN = 22  # GPIO 22 (pin 13)

# Initialize the DHT22 sensor
dhtDevice = adafruit_dht.DHT22(board.D18)

def read_moisture():
    """Read analog moisture level from sensor on GPIO 22"""
    # For analog reading, we need to use GPIO as input
    GPIO.setup(MOISTURE_PIN, GPIO.IN)
    
    # Read the moisture level (analog value)
    # Higher value typically means drier soil
    # Lower value typically means moister soil
    moisture_value = GPIO.input(MOISTURE_PIN)
    
    moisture_percentage = moisture_value * 100.0 / 1023.0
    moisture_percentage = 100 - moisture_percentage  # Invert so 100% means very wet
    
    return moisture_percentage

try:
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
                
            
            # Print all the values
            print("+---------------+---------------+---------------+")
            print("| Temperature   | Air Humidity  | Soil Moisture |")
            print("+---------------+---------------+---------------+")
            print(f"| {temperature_c:.1f}°C        | {humidity:.1f}%         | {moisture:.1f}%        |")
            print("+---------------+---------------+---------------+")

        except RuntimeError as error:
            print(error.args[0])
            time.sleep(2.0)
            continue
        except Exception as error:
            dhtDevice.exit()
            GPIO.cleanup()  # Clean up GPIO on exit
            raise error

        time.sleep(2.0)
        
except:
    GPIO.cleanup()  