# Specification and Design of a Flutter-based Qibla Direction App

## 1. Introduction
This application helps users determine the Qibla direction (the direction of the Ka'bah in Masjid al‑Harām, Mecca) by using the device’s compass and GPS sensors. It is built with Flutter so it runs on both Android and iOS from a single code base.

## 2. Goals
- Provide an accurate real‑time Qibla direction.
- Use the compass for device orientation and GPS for the user's location.
- Visualise the direction with a rotating arrow or compass that points toward Qibla relative to magnetic north.
- Display the user's latitude, longitude, and distance to the Ka'bah.

## 3. Core Features
| # | Feature | Description |
|---|---------|-------------|
| 1 | Location detection | Use the `geolocator` plugin to obtain the user's latitude and longitude. |
| 2 | Compass reading | Use `flutter_compass` or `sensors_plus` to obtain the azimuth (angle relative to magnetic north). |
| 3 | Qibla calculation | Compute the bearing from the user’s location to the Ka'bah (21.4225° N, 39.8262° E) using the haversine formula. |
| 4 | Direction visualisation | Show a digital compass with a rotating arrow that aligns with the calculated Qibla bearing. |
| 5 | Information display | Show latitude, longitude, location accuracy, distance to the Ka'bah, and the last update timestamp. |
| 6 | Compass calibration | Provide a "figure‑8" gesture instruction when calibration is required. |
| 7 | Offline mode | Cache the last known location and compass heading for use when GPS is unavailable. |
| 8 | Settings | Choose distance units (meters/kilometers), light/dark theme, and automatic update notifications. |

## 4. Functional Requirements
- The app must request and obtain permissions for location and compass sensors at runtime.
- Qibla bearing calculation should complete within 1 second for a responsive UI.
- The UI must adapt to both portrait and landscape orientations.
- The app must gracefully handle missing compass hardware by showing an appropriate error message.
- When permissions are denied, the app should guide the user to enable them in the system settings.

## 5. Non‑Functional Requirements
- **Performance**: UI rendering > 60 FPS.
- **Battery**: Minimise sensor usage; pause streams when the app moves to the background.
- **Privacy**: No location data is transmitted to external servers; all calculations are performed locally.
- **Compatibility**: Android 5.0 (API 21) and iOS 12.0 or newer.
- **App size**: Target a release bundle < 30 MB (Flutter apps typically exceed 15 MB).
- **Security**: Permissions are requested only at runtime and never persisted in storage.

## 6. Architecture Overview
```
lib/
├── main.dart
├── core/
│   ├── utils/
│   │   ├── location_helper.dart   // wrapper around geolocator
│   │   ├── compass_helper.dart    // wrapper around compass sensor
│   │   ├── qibla_calc.dart        // haversine + bearing calculation
│   │   └── constants.dart        // app‑wide constants (e.g., Ka'bah coordinates)
│   └── services/
│       ├── location_service.dart
│       └── compass_service.dart
├── features/
│   └── qibla/
│       ├── ui/
│       │   ├── qibla_page.dart
│       │   └── qibla_compass_painter.dart   // CustomPaint implementation
│       ├── viewmodel/
│       │   └── qibla_viewmodel.dart        // State management (Provider or Riverpod)
│       └── repository/
│           └── qibla_repository.dart
├── themes/
│   └── app_theme.dart
└── assets/
    └── images/        // compass icons, arrow SVGs, etc.
```
- State management: **Provider** for simplicity or **Riverpod** for greater scalability.
- Location and compass services are singleton objects exposing `Stream`s.
- The UI draws the compass using `CustomPaint` for high performance.

## 7. Data Flow
1. Request runtime permissions for location and sensor.
2. `LocationService` starts a location stream.
3. `CompassService` starts a heading (azimuth) stream.
4. Streams are combined (e.g., using `Rx.combineLatest2`) to produce a unified data model.
5. `QiblaViewModel` receives the combined data, calls `QiblaCalculator.bearing()` to compute the Qibla bearing.
6. The bearing is exposed via a `ChangeNotifier`/`StateNotifier`.
7. `QiblaPage` listens to the notifier and:
   - Rotates the compass arrow based on `heading – bearing`.
   - Updates textual information (coordinates, distance, timestamp).

## 8. Technology Stack & Plugins
| Need | Plugin (pub.dev) | Notes |
|------|------------------|-------|
| Location | `geolocator: ^10.0.0` | GPS access and permission handling |
| Compass | `flutter_compass: ^0.5.0` or `sensors_plus: ^4.0.0` | Provides azimuth readings |
| State Management | `provider: ^6.0.0` (or `riverpod: ^2.0.0`) | Simple or scalable state handling |
| Graphics | `flutter_svg: ^2.0.0` (optional) | SVG assets for compass graphics |
| Streams | `rxdart: ^0.28.0` | Stream composition utilities |
| Logging | `logger: ^2.0.0` | Structured logging |
| Permissions | `permission_handler: ^11.0.0` | Centralised runtime permission requests |
| Splash & Icons | `flutter_native_splash: ^2.3.0`, `flutter_launcher_icons: ^0.13.1` | App startup splash screen and launcher icons |

## 9. Privacy & Security Note
- No location data is sent to any external service.
- Permissions are requested only while the app is in the foreground.
- Cached location/heading data is kept in memory only and cleared when the app is terminated.
- A short privacy policy will be included in the Play Store and App Store listings, describing the above points.

---
*This specification serves as a development reference. Adjustments may be made as the project evolves.*

**Flutter Application ID:** `id.web.sofy.qiblacompass`