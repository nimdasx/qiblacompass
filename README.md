# Aira Qibla Compass

**Aira Qibla Compass** is a Flutter application that helps users determine the Qibla direction by combining device location data and compass heading. The app calculates the bearing and distance to the Ka'bah in Mecca locally on the device, then visualizes the direction through a custom compass.

- **App ID:** `id.web.sofy.qiblacompass`
- **Version:** 0.1.0+1
- **Flutter SDK:** ^3.11.5
- **Target platforms:** Android & iOS (primary); desktop/web scaffolding is present but not actively developed

---

## Features

| # | Feature | Description |
|---|---------|-------------|
| 1 | GPS location detection | Position stream with `LocationAccuracy.high`, updates every 10 meters |
| 2 | Compass reading | Heading stream from `FlutterCompass.events` |
| 3 | Qibla calculation | `bearingBetween` + `distanceBetween` via `geolocator` to Ka'bah coordinates |
| 4 | Compass visualization | `CustomPainter` — circle, tick marks, cardinals (N red / E S W teal), amber Qibla arrow |
| 5 | Location information | Latitude, longitude, and distance to Mecca (km) |
| 6 | Location fallback | Last known position → `SharedPreferences` cache |
| 7 | Responsive layout | `LayoutBuilder` + `SingleChildScrollView`, compass size clamped to 220–420px |
| 8 | Light/dark theme | `ThemeMode.system`, teal + amber, Material 3 |
| 9 | Unit tests | 3 tests: zero distance at Ka'bah, bearing from Jakarta, distance from Jakarta |
| 10 | Duplicate stream guard | `_initToken` prevents duplicate subscriptions on retry |

### Not Yet Implemented

- Compass calibration guidance (figure-8 motion instructions)
- GPS location accuracy display
- Last location update timestamp
- Distance unit settings (km / miles)
- In-app theme selection
- Notifications
- Deep link to system settings for permanently denied permissions
- Explicit app lifecycle handling (pause streams while backgrounded)
- Android release signing for production

---

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.5 (latest stable recommended)
- A physical device — compass sensors are often unavailable or inaccurate on emulators/simulators

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/nimdasx/qiblacompass.git
   cd qiblacompass
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run on a connected device:
   ```bash
   flutter run
   ```

### Quality Checks

```bash
flutter analyze
flutter test
```

---

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern with dependency injection via `Provider`.

```
main.dart
  └── MultiProvider
        ├── LocationService       (Provider)
        ├── CompassService        (Provider)
        └── QiblaViewModel        (ChangeNotifierProvider)
              └── QiblaPage       (Consumer<QiblaViewModel>)
                    └── QiblaCompassPainter  (CustomPainter)
```

- `main.dart` wires dependencies with `Provider` and `ChangeNotifierProvider`
- `LocationService` wraps `geolocator` permission, stream, last-known location, and cached coordinate access
- `CompassService` wraps heading events from `flutter_compass`
- `QiblaViewModel` combines location and compass streams, owns UI state, and prevents duplicate subscriptions on retry
- `QiblaCalc` performs bearing and distance calculations to the Ka'bah
- `QiblaPage` renders four states: loading, error, waiting, and compass
- `QiblaCompassPainter` draws the compass face, cardinal markers, and Qibla arrow

### Data Flow

1. `main.dart` creates `LocationService`, `CompassService`, and `QiblaViewModel`
2. `QiblaViewModel._init()` requests/checks location permission through `LocationService`
3. If permission is unavailable → the ViewModel exposes an error message for `QiblaPage`
4. If permission is available → the ViewModel tries `getLastKnownLocation()`
5. If no last known location exists → the ViewModel tries cached coordinates from `SharedPreferences`
6. The ViewModel starts the location and compass streams
7. `Rx.combineLatest2` emits once both a `Position` and a `CompassEvent` are available
8. The latest location is cached locally (`unawaited` — fire-and-forget to avoid blocking the UI)
9. `QiblaCalc` calculates the Qibla bearing and distance
10. `QiblaPage` rebuilds from `ChangeNotifier` notifications and passes heading/bearing to `QiblaCompassPainter`

### Project Structure

```
lib/
├── main.dart                           # Entry point, MultiProvider wiring
├── themes/
│   └── app_theme.dart                  # Light & dark theme (Material 3, teal + amber)
├── core/
│   ├── utils/
│   │   ├── constants.dart              # Ka'bah coordinates (21.422487, 39.826206)
│   │   └── qibla_calc.dart             # Bearing & distance calculation to Ka'bah
│   └── services/
│       ├── location_service.dart       # geolocator wrapper + SharedPreferences cache
│       └── compass_service.dart        # flutter_compass heading stream wrapper
└── features/
    └── qibla/
        ├── ui/
        │   ├── qibla_page.dart         # Main UI: 4 states (loading/error/waiting/compass)
        │   └── qibla_compass_painter.dart  # CustomPainter: compass face + Qibla arrow
        └── viewmodel/
            └── qibla_viewmodel.dart    # ChangeNotifier, stream combinator, state

test/
└── core/
    └── utils/
        └── qibla_calc_test.dart        # Unit tests: bearing & distance from Jakarta
```

---

## Technology Stack

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Cross-platform UI framework |
| `provider` | ^6.1.5+1 | Dependency injection & `ChangeNotifier` state management |
| `geolocator` | ^14.0.2 | GPS, location permission, last known position, bearing, distance |
| `flutter_compass` | ^0.8.1 | Heading stream from the device compass sensor |
| `rxdart` | ^0.28.0 | `combineLatest2` to merge location and compass streams |
| `shared_preferences` | ^2.5.5 | Cache last coordinates as location fallback |
| `logger` | ^2.7.0 | Error & warning logging in the service layer |
| `flutter_lints` | ^6.0.0 | Static analysis rules |
| `flutter_launcher_icons` | ^0.14.4 | Launcher icon generation from `assets/images/logo.png` |
| `flutter_native_splash` | ^2.4.7 | Native splash screen configuration |

---

## Platform Configuration

### Android

The app requests runtime permissions for:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`

Release signing is not yet configured for production builds.

### iOS

The app requests runtime location permission. Ensure `NSLocationWhenInUseUsageDescription` and `NSLocationAlwaysUsageDescription` are defined in `ios/Runner/Info.plist`.

---

## Building for Release

**Android:**
```bash
flutter build appbundle
```

**iOS:**
```bash
flutter build ipa
```

---

## Privacy & Security

- No location data is sent to any external API
- All bearing and distance calculations are performed entirely on-device
- Cached data is limited to latitude and longitude in local app storage
- Location permission is requested at runtime

---

## License

This project is licensed under the MIT License.
