import 'package:flutter/material.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/utils/router.dart';
import 'package:bockaire/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();
  runApp(const BockaireApp());
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
