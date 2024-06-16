import 'package:flutter/material.dart';
import 'package:studentportfolio_app/database/database_sqflite.dart';
import 'package:studentportfolio_app/screens/splash_screen.dart';

const Savekey = 'UserLoggedIn';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const ScreenSplash(),
    );
  }
}
