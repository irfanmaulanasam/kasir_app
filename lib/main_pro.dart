import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/flavor_config.dart';
// import 'data/remote/sync_service.dart'; // Contoh import remote

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set konfigurasi ke Pro
  FlavorConfig.set(Flavor.pro, "Kasir Pro (Cloud Sync)");

  // Inisialisasi Cloud hanya ada di file ini
  // await CloudService.init(); 

  runApp(const MyApp());
}