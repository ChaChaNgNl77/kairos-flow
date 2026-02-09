import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/archive_item.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';  

void main() async {
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  Hive.registerAdapter(ArchiveItemAdapter());

  await Hive.openBox<ArchiveItem>('archives');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What If I Do Nothing?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E4B28),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5DC),
        useMaterial3: true,
      ),
      home: HomeScreen(
        hasSavedData: Hive.box<ArchiveItem>('archives').isNotEmpty,
      ),
    );
  }
}
