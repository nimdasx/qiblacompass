# Specification and Design of Aira Qibla Compass

## 1. Introduction
Aira Qibla Compass is a Flutter application that helps users determine the Qibla direction by combining the device's location and compass heading. The app calculates the bearing and distance to the Ka'bah in Mecca locally on the device, then visualizes the direction through a custom compass.

The current implementation targets mobile use first. Android and iOS project configuration is present, while desktop and web folders remain generated Flutter platform scaffolding.

## 2. Goals
- Provide a real-time Qibla direction from the user's current location.
- Use GPS/location services for latitude and longitude.
- Use the device compass for heading relative to magnetic north.
- Display the user's latitude, longitude, and distance to the Ka'bah.
- Keep Qibla calculations local and avoid transmitting location data to external services.
- Provide a fallback from the last known or cached location while waiting for fresh GPS data.

## 3. Current Features
| # | Feature | Status | Description |
|---|---------|--------|-------------|
| 1 | Location detection | Implemented | Uses `geolocator` to request permissions and stream position updates. |
| 2 | Compass reading | Implemented | Uses `flutter_compass` to stream heading events. |
| 3 | Qibla calculation | Implemented | Uses `Geolocator.bearingBetween` and `Geolocator.distanceBetween` with Ka'bah coordinates. |
| 4 | Direction visualization | Implemented | Uses `CustomPainter` to draw a compass and Qibla arrow. |
| 5 | Basic information display | Implemented | Shows latitude, longitude, and distance to Mecca. |
| 6 | Last location fallback | Implemented | Uses last known location first, then falls back to locally cached coordinates. |
| 7 | Responsive layout | Implemented | Uses a scroll-safe layout with adaptive compass sizing. |
| 8 | Light/dark theme | Implemented | Follows the system theme through `ThemeMode.system`. |
| 9 | Unit tests | Implemented | Covers Qibla bearing and distance calculations. |

## 4. Not Implemented Yet
The following items are future scope and should not be described as available app features until built:

- Compass calibration guidance, such as figure-8 instructions.
- Location accuracy display.
- Last update timestamp display.
- Unit settings for distance display.
- In-app theme selection.
- Notification settings.
- Graceful system-settings deep link for permanently denied permissions.
- Explicit app lifecycle handling to pause streams while backgrounded.
- Production Android release signing.

## 5. Functional Requirements
- The app requests runtime location permission through `geolocator`.
- If permission is denied or location services are disabled, the UI shows an error state and a retry action.
- Once permission is available, the app attempts to load a last known location before waiting for stream updates.
- Fresh location stream values are cached locally via `shared_preferences`.
- Location and compass streams are combined in `QiblaViewModel` using `Rx.combineLatest2`.
- The compass screen updates when either fresh location or heading values arrive.
- Retry must not create duplicate stream subscriptions.
- The main Qibla UI must remain usable on small screens and landscape layouts.

## 6. Non-Functional Requirements
- **Performance**: Compass rendering should remain lightweight and suitable for smooth UI updates.
- **Privacy**: Location data is calculated locally and is not sent to external services by the app.
- **Persistence**: Only the last latitude and longitude are stored locally for fallback behavior.
- **Compatibility**: The app is configured through Flutter's generated Android/iOS platform projects and plugin requirements.
- **Maintainability**: Business logic stays outside UI widgets where practical, with services handling hardware/plugin access and the viewmodel coordinating state.

## 7. Architecture Overview
```text
lib/
├── main.dart
├── core/
│   ├── services/
│   │   ├── compass_service.dart
│   │   └── location_service.dart
│   └── utils/
│       ├── constants.dart
│       └── qibla_calc.dart
├── features/
│   └── qibla/
│       ├── ui/
│       │   ├── qibla_compass_painter.dart
│       │   └── qibla_page.dart
│       └── viewmodel/
│           └── qibla_viewmodel.dart
└── themes/
    └── app_theme.dart

test/
└── core/
    └── utils/
        └── qibla_calc_test.dart
```

- `main.dart` wires dependencies with `Provider` and `ChangeNotifierProvider`.
- `LocationService` wraps `geolocator` permission, stream, last-known location, and cached coordinate access.
- `CompassService` wraps `flutter_compass` heading events.
- `QiblaViewModel` combines location and compass streams, owns UI state, and avoids duplicate subscriptions on retry.
- `QiblaCalc` performs bearing and distance calculations to the Ka'bah.
- `QiblaPage` renders loading, error, waiting, and compass states.
- `QiblaCompassPainter` draws the compass face, cardinal markers, and Qibla arrow.

## 8. Data Flow
1. `main.dart` creates `LocationService`, `CompassService`, and `QiblaViewModel`.
2. `QiblaViewModel` requests/checks location permission through `LocationService`.
3. If permission is unavailable, the viewmodel exposes an error message for `QiblaPage`.
4. If permission is available, the viewmodel tries `getLastKnownLocation()`.
5. If no last known location exists, the viewmodel tries locally cached coordinates.
6. The viewmodel starts the location and compass streams.
7. `Rx.combineLatest2` emits once both a `Position` and `CompassEvent` are available.
8. The latest location is cached locally.
9. `QiblaCalc` calculates the Qibla bearing and distance.
10. `QiblaPage` rebuilds from `ChangeNotifier` state and passes heading/bearing values to `QiblaCompassPainter`.

## 9. Technology Stack & Plugins
| Need | Package | Notes |
|------|---------|-------|
| Framework | `flutter` | Cross-platform UI framework. |
| State management | `provider: ^6.1.5+1` | Dependency injection and `ChangeNotifier` state updates. |
| Location | `geolocator: ^14.0.2` | Location permission, last known position, position stream, bearing, and distance helpers. |
| Compass | `flutter_compass: ^0.8.1` | Heading stream from device compass sensors. |
| Streams | `rxdart: ^0.28.0` | Combines location and compass streams. |
| Local cache | `shared_preferences: ^2.5.5` | Stores last latitude and longitude fallback. |
| Logging | `logger: ^2.7.0` | Logs service-level errors and warnings. |
| Lints | `flutter_lints: ^6.0.0` | Static analysis rules. |
| Icons | `flutter_launcher_icons: ^0.14.4` | Launcher icon generation configuration. |
| Splash | `flutter_native_splash: ^2.4.7` | Splash configuration dependency. |

## 10. Privacy & Security Note
- No location data is sent to an external API by this app.
- Bearing and distance calculations are performed locally.
- Cached fallback data is limited to latitude and longitude in local app storage.
- Location permission is requested at runtime.
- iOS location usage strings are configured in `ios/Runner/Info.plist`.
- Android fine and coarse location permissions are configured in `android/app/src/main/AndroidManifest.xml`.

## 11. Validation
Current quality checks:

```bash
flutter analyze
flutter test
```

The test suite currently covers:

- Zero distance at the Ka'bah coordinates.
- Expected Qibla bearing from Jakarta.
- Expected distance from Jakarta to the Ka'bah.

---
This specification describes the current implementation as of the latest project changes. Future features should update this document when implemented.

**Flutter Application ID:** `id.web.sofy.qiblacompass`
