import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convogen/providers/theme_provider.dart';
import 'package:convogen/router/router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart' as provider;
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(
      enabled: false,
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
      ).copyWith(
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
          decorationColor: Colors.white,
          decoration: TextDecoration.none,
        ),
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.teal,
          background: Colors.blueGrey.shade900,
          secondary: Colors.teal,
          brightness: Brightness.dark,
          onBackground: Colors.white,
          onSecondary: Colors.white,
          primaryContainer: Colors.teal,
          onSurface: Colors.white,
          surface: Colors.blueGrey.shade900,
        ),
      ),
      themeAnimationDuration: Duration.zero,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal).copyWith(),
        useMaterial3: true,
      ),
    );
  }
}
