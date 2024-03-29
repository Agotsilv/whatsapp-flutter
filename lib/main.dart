import 'package:firebase_core/firebase_core.dart';
import 'package:whats/RouteGenerator.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:whats/LoginUser/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(
    // home: Login(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    onGenerateRoute: RouteGenerator.generateRoute,
    )
  );
}

