import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:go_plan_v8/LoginPage/login_screen.dart';
import 'package:go_plan_v8/Trip/add_trip.dart';
import 'package:go_plan_v8/Trip/trip_screen.dart';

class UserState extends StatelessWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot){
        if(userSnapshot.data == null){
          print('user is not logged in yet');
          return const Login();
        }else if(userSnapshot.hasData){
          print("user is already logged in yet");
          return const TripScreen();
        }
        else if(userSnapshot.hasError){
          return const Scaffold(
            body: Center(
              child: Text(
                "An error has been occurred. Try again later",
              ),
            ),
          );
        }
        else if(userSnapshot.connectionState==ConnectionState.waiting){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: Text("Something went wrong"),
          ),
        );
      },
    );
  }
}