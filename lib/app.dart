import 'package:flutter/material.dart';

import 'screens/weather_screen.dart';
import 'services/weather_service.dart';
import 'services/favorites_store.dart';

class LangitKitaApp extends StatelessWidget {
  const LangitKitaApp({super.key, this.service, this.favoritesStore});

  final WeatherService? service;
  final FavoritesStore? favoritesStore;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF173E38);
    return MaterialApp(
      title: 'LangitKita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: ink,
          primary: ink,
          surface: const Color(0xFFF7F8F2),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8F2),
          foregroundColor: ink,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFDAE2D8)),
          ),
        ),
      ),
      home: WeatherScreen(service: service, favoritesStore: favoritesStore),
    );
  }
}
