# NSW COVID-19 Tracker

[![GitHub license](https://img.shields.io/github/license/nsw-covid19-tracker/app)](https://github.com/nsw-covid19-tracker/app/blob/master/LICENSE)
[![Build and Deploy](https://github.com/nsw-covid19-tracker/app/workflows/Build%20and%20Deploy/badge.svg)](https://github.com/nsw-covid19-tracker/app/actions?query=workflow%3A%22Build+and+Deploy%22)
[![Effective Dart](https://img.shields.io/badge/style-Effective%20Dart-40c4ff.svg)](https://github.com/google/pedantic)

The intent for this app is before you visit a venue you can check if there have been any confirmed cases or retrospectively check if you have been to any location with confirmed cases.

**Download APK:** [Link](https://appdistribution.firebase.dev/i/57b34e104803998d)

![Screenshots](images/screenshots.png)

## Getting Started

### Setup Flutter

To install and setup Flutter, follow the instructions [here](https://flutter.dev/docs/get-started/install).

### Setup Firebase

Create a new project on Firebase.

- For iOS, create an iOS app and download the config file `GoogleService-info.plist`, and place it under `ios/Runner/`. Open Xcode and select `ios/Runner/Runner.xcworkspace` to open it as the project. Drag the config file into Xcode under `Runner` and make sure to add it to all targets.
- For Android, create and Android app and download the config file `google-services.json`, and place it under `android/app/`.

#### Authentication

Enable Anonymous sign in in the Authentication tab.

#### Realtime Database

Enable Realtime Database by going into the corresponding tab.

### Setup Google Maps

Follow the instructions [here](https://pub.dev/packages/google_maps_flutter#getting-started) to setup Google Maps.

### Setup Database

Follow the instructions [here](https://github.com/nsw-covid19-tracker/functions) to fetch and store the data.

### Setup and Running the App

Navigate back to the root of the project and run the command below to install the Flutter packages:

    flutter pub get

Run the code generator:

    flutter pub run build_runner build

Run the app:

    flutter run
