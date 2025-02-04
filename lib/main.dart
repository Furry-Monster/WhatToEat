import 'package:flutter/material.dart';
import 'package:witch_one/screens/main_screen.dart';
import 'package:witch_one/theme/app_theme.dart';
import 'package:witch_one/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '吃什么',
      debugShowCheckedModeBanner: AppTheme.showDebugBanner,
      theme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
