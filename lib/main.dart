import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/utils/router.dart';
import 'package:bockaire/themes/theme.dart';
import 'package:bockaire/database/seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();

  // Seed the database with initial data
  final seeder = DatabaseSeeder(getIt.get());
  await seeder.seedAll();

  runApp(const ProviderScope(child: BockaireApp()));
}

class BockaireApp extends StatelessWidget {
  const BockaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bockaire - Shipping Optimizer',
      theme: createAppTheme(brightness: Brightness.light),
      darkTheme: createAppTheme(brightness: Brightness.dark),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
