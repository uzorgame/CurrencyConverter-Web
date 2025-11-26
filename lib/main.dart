import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/currency_provider.dart';
import 'repositories/currency_repository.dart';
import 'screens/home_screen.dart';
import 'services/currency_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repository = CurrencyRepository(
    api: CurrencyApi(),
    preferences: prefs,
  );

  runApp(CurrencyApp(repository: repository));
}

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key, required this.repository});

  final CurrencyRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CurrencyProvider(repository: repository)..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Currency Converter',
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.teal,
            secondary: Colors.tealAccent,
          ),
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
