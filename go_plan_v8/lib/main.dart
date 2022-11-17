import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_plan_v8/LoginPage/login_screen.dart';
import 'package:go_plan_v8/user_state.dart';
import 'package:intl/intl.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp( MyApp());
}

class MyApp extends StatelessWidget { 

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text('Go Plan is being initialized',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kanit'
                ),),
              ),
            )
          );
        }
        else if(snapshot.hasError){
          
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text('An error has been occurred',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Kanit'
                ),),
              ),
            )
          );
        }
        return  MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Go Plan',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            primarySwatch: Colors.blue,
            errorColor: Colors.white,
            fontFamily: 'Kanit',
          ),
          home: const UserState(),
        );
      },
    );
  }
}
