import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/flavor_config.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(
    'id_ID',
    null,
  );

  FlavorConfig.set(
    Flavor.advanced,
    "Kasir Advanced",
  );

  runApp(const MyApp());
}