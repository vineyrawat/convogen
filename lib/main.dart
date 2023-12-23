import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convogen/providers/theme_provider.dart';
import 'package:convogen/router/router.dart';
import 'package:provider/provider.dart' as provider;
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(
      enabled: !kReleaseMode,
      builder: ((context) => ProviderScope(
            child: provider.ChangeNotifierProvider(
                create: (context) => ThemeNotifier(), child: const MyApp()),
          ))));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
      title: 'Convogen',
      debugShowCheckedModeBanner: false,
      themeMode: provider.Provider.of<ThemeNotifier>(context).themeMode,
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      themeAnimationDuration: Duration.zero,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
    );
  }
}
