# OLAF – OnLine Automated Farm

## Overview

OLAF is a "Moonshot Project" developed as part of ALGOSUP's end-of-study curriculum. These projects are designed to be ambitious, innovative, and technically challenging, encouraging students to create something meaningful and original through coding.

## What is OLAF?

OLAF stands for **OnLine Automated Farm**. It’s a smart farming concept aimed at personal, non-commercial use. The project includes a companion mobile app that allows users to:

- Add and manage plant pots
- Access a plant and disease lexicon
- Detect diseases on plant leaves using image analysis

## How It Works

At the core of OLAF’s disease detection system is an AI-based image classification pipeline. Here's a breakdown:

- **Model**: The app uses the **ConvNeXt Tiny** architecture, a modern convolutional neural network known for its accuracy and efficiency.
- **Dataset**: The model was trained using data from [PlantPAD](https://plantpad.samlab.cn/index.html), a comprehensive plant disease image dataset.
- **Frontend**: The mobile application is built with **Flutter**, ensuring a smooth and responsive user experience.
- **Backend**: All server-side operations, such as model inference and data handling, are powered by **AWS (Amazon Web Services)**.

## Getting Started

Currently, the mobile app is available exclusively on Android.

OLAF will soon be released on the Google Play Store. If you cannot find it on the Play Store, you can alternatively follow these steps to install and use the app:

1. Connect your Android phone to your computer.
2. Download the APK file from the latest release.
3. Move the APK to your phone’s **Download** folder.
4. On your phone, locate the APK file and tap it to begin installation.
5. Follow the prompts to complete the installation.

Once installed, you’re ready to explore OLAF!

