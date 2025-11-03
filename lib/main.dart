import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Loginpage.dart';  // 👈 thêm import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "assets/.env");
    debugPrint('Loaded .env: ${dotenv.env}');
  } catch (e) {
    debugPrint('Error loading .env: $e');
    // Fallback to default values if .env file is not found
    dotenv.env['APIURLKEY'] = 'https://6ws3b9vr-3000.asse.devtunnels.ms';
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // ẩn banner DEBUG
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),  // 👈 mở thẳng CustomerLoginPage
    );
  }
}
