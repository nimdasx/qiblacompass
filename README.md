# Aira Qibla Compass

**Aira Qibla Compass** — A Flutter application that calculates and displays the Qibla direction using the device location and compass sensors.

This application helps users determine the precise direction of the Qibla (the Ka'bah in Masjid al-Harām, Mecca) from anywhere in the world by utilizing the device's GPS and compass sensors. It functions seamlessly on both Android and iOS devices.

## 🎯 Features

*   **Real-time Accurate Direction:** Computes the bearing to the Qibla relative to magnetic north.
*   **Custom Compass:** Uses a `CustomPainter` to render a compass with a dynamic Qibla arrow indicator.
*   **Distance & Location Info:** Displays the user's current latitude, longitude, and precise distance to Mecca.
*   **Last Location Fallback:** Uses the device's last known location or a locally cached location while waiting for fresh GPS data.
*   **Privacy-First:** All calculations are performed strictly locally on the device. No user location data is transmitted to external servers.
*   **Responsive UI:** Uses a scroll-safe layout and supports both light and dark modes.

## 🛠️ Technology Stack

*   **Framework:** Flutter (Dart)
*   **State Management:** Provider
*   **Location Services:** `geolocator`
*   **Compass/Heading:** `flutter_compass`
*   **Reactive Streams:** `rxdart`
*   **Local Cache:** `shared_preferences`

## 🏗️ Architecture

The app is built with a clean, modular architecture separating the UI from the business logic and services:

*   **`lib/core/`**: Contains utility classes (Qibla calculator, constants) and hardware interaction services (`location_service`, `compass_service`).
*   **`lib/features/qibla/`**: Holds the core Qibla feature divided into `ui` (pages, painters) and `viewmodel` (handling business logic and stream aggregation).
*   **`lib/themes/`**: Contains the design system and light/dark theme configurations.

## ✅ Current Scope

Implemented:

*   Runtime location permission flow through `geolocator`.
*   Real-time location and compass stream aggregation.
*   Bearing and distance calculation to the Ka'bah.
*   Last-known/cached location fallback.
*   Basic responsive Qibla compass screen.
*   Unit tests for the Qibla calculation utility.

Not implemented yet:

*   Compass calibration guidance.
*   Settings for units, theme selection, or notifications.
*   Location accuracy and last update timestamp display.
*   Production release signing configuration.

## 🚀 Getting Started

### Prerequisites

*   Flutter SDK (latest stable version recommended)
*   A physical device (Compass sensors are often unavailable or inaccurate on emulators/simulators)

### Installation

1.  Clone this repository:
    ```bash
    git clone https://github.com/nimdasx/qiblacompass.git
    cd qiblacompass
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application on a connected device:
    ```bash
    flutter run
    ```

### Quality Checks

```bash
flutter analyze
flutter test
```

### Android Permissions
The app requests runtime permissions for:
*   `ACCESS_FINE_LOCATION`
*   `ACCESS_COARSE_LOCATION`

### iOS Permissions
The app requests runtime permissions for Location usage. Make sure to define `NSLocationWhenInUseUsageDescription` and `NSLocationAlwaysUsageDescription` in `ios/Runner/Info.plist`.

## ⚙️ Building for Release

To generate an Android App Bundle or an iOS IPA, use standard Flutter build commands.

**Android:**
```bash
flutter build appbundle
```

**iOS:**
```bash
flutter build ipa
```

## 📝 License

This project is licensed under the MIT License.
