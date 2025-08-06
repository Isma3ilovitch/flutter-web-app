import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

// --- WEB-SPECIFIC SETUP ---
// We need to ensure the web app is correctly initialized.
Future<void> main() async {
  // This is crucial for Flutter Web
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared_preferences for web storage
  await SharedPreferences.getInstance();
  
  runApp(const WarrantyKeeperApp());
}

class WarrantyKeeperApp extends StatelessWidget {
  const WarrantyKeeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warranty Keeper (Web)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Make text a bit larger for desktop viewing
        textTheme: Theme.of(context).textTheme.apply(bodyFontSize: 16),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
