import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plant/firebase_options.dart';
import 'package:plant/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), // 클래스 이름은 보통 대문자로 시작합니다.
    );
  }
}