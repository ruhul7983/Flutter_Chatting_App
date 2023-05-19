
import 'package:chatapp/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



late Size mq;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapSpeak',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
        )
      ),
      home: splashScreen(),
    );
  }
}

