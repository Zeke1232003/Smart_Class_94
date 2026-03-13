import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/firebase_service.dart';
import 'screens/checkin_screen.dart';
import 'screens/finish_class_screen.dart';
import 'screens/home_screen.dart';
import 'screens/records_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  await FirebaseService.initialize();
  runApp(const SmartClassApp());
}

class SmartClassApp extends StatelessWidget {
  const SmartClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Class Check-in',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const HomeScreen(),
        '/checkin': (_) => const CheckInScreen(),
        '/finish': (_) => const FinishClassScreen(),
        '/records': (_) => const RecordsScreen(),
      },
      initialRoute: '/',
    );
  }
}
