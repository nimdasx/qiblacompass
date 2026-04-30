import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/location_service.dart';
import 'core/services/compass_service.dart';
import 'features/qibla/viewmodel/qibla_viewmodel.dart';
import 'features/qibla/ui/qibla_page.dart';
import 'themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<CompassService>(create: (_) => CompassService()),
        ChangeNotifierProvider<QiblaViewModel>(
          create: (context) => QiblaViewModel(
            context.read<LocationService>(),
            context.read<CompassService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Qibla Compass',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const QiblaPage(),
      ),
    );
  }
}
