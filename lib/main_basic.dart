import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/flavor_config.dart';

void main() {
  // Set konfigurasi ke Basic
  FlavorConfig.set(Flavor.basic, "Kasir Lite (Offline)");
  
  runApp(const MyApp());
}