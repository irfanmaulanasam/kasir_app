import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/flavor_config.dart';

void main() {
  FlavorConfig.set(Flavor.advanced, "Kasir Advanced (Scan)");
  runApp(const MyApp());
}