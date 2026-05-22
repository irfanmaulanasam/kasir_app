import 'package:flutter/material.dart';

import 'core/config/flavor_config.dart';

import 'ui/dashboard/dashboard_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: FlavorConfig.instance.appTitle,

      theme: ThemeData(

  useMaterial3: true,

    inputDecorationTheme:
        const InputDecorationTheme(

      border: OutlineInputBorder(),

      enabledBorder: OutlineInputBorder(),

      focusedBorder: OutlineInputBorder(),

      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
  ),

      home: const DashboardPage(),
    );
  }
}