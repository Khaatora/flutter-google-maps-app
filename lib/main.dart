import 'package:flutter/material.dart';
import 'package:google_maps_app/core/constants/app_routes.dart';
import 'package:google_maps_app/home/view/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Getter',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.homeScreen,
      routes: {
        AppRoutes.homeScreen : (context) => const HomeScreen(),
      },
    );
  }
}
