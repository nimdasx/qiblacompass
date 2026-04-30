# Qibla Compass

A beautifully designed, accurate, and offline-capable Qibla direction application built with Flutter.

This application helps users determine the precise direction of the Qibla (the Ka'bah in Masjid al-Harām, Mecca) from anywhere in the world by utilizing the device's GPS and compass sensors. It functions seamlessly on both Android and iOS devices.

## 🎯 Features

*   **Real-time Accurate Direction:** Computes the bearing to the Qibla relative to magnetic north.
*   **Beautiful Custom Compass:** Uses a performant `CustomPainter` to render a smooth, elegant compass with a dynamic Qibla arrow indicator.
*   **Distance & Location Info:** Displays the user's current latitude, longitude, and precise distance to Mecca.
*   **Offline Mode Support:** Relies on the device's hardware sensors, requiring no external API calls for location or direction (once location is acquired).
*   **Privacy-First:** All calculations are performed strictly locally on the device. No user location data is transmitted to external servers.
*   **Responsive UI:** Adapts gracefully to different screen orientations and supports both Light and Dark modes.

## 🛠️ Technology Stack

*   **Framework:** Flutter (Dart)
*   **State Management:** Provider
*   **Location Services:** `geolocator`
*   **Compass/Heading:** `flutter_compass`
*   **Reactive Streams:** `rxdart`
*   **Permissions:** `permission_handler`

## 🏗️ Architecture

The app is built with a clean, modular architecture separating the UI from the business logic and services:

*   **`lib/core/`**: Contains utility classes (Qibla calculator, constants) and hardware interaction services (`location_service`, `compass_service`).
*   **`lib/features/qibla/`**: Holds the core Qibla feature divided into `ui` (pages, painters) and `viewmodel` (handling business logic and stream aggregation).
*   **`lib/themes/`**: Contains the design system and light/dark theme configurations.

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
