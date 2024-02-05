import 'package:firebase_core/firebase_core.dart';
import 'package:lab3_mis/screens/signin_screen.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'AIzaSyAOVJeZI17jk0c6Qxho0NfxKLRjAn8uhw0',
    authDomain: 'lab3-6d2c4.firebaseapp.com',
    projectId: 'lab3-6d2c4',
    storageBucket: 'lab3-6d2c4.appspot.com',
    messagingSenderId: '972638178048',
    appId: '1:972638178048:web:9e4c582fe7066667e5c1e5',
  ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const SignInScreen(),
    );
  }
}