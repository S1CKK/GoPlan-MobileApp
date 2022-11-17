import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_plan_v8/Page/my_trip.dart';
import 'package:go_plan_v8/Trip/add_trip.dart';
import 'package:go_plan_v8/Trip/trip_screen.dart';
import 'package:go_plan_v8/user_state.dart';

import '../Page/profile.dart';
import '../Page/fav_trip.dart';

class BottomNavigationBarForApp extends StatelessWidget {
  int indexNum = 0;
  BottomNavigationBarForApp({required this.indexNum});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color:Color.fromARGB(255, 10, 56, 135),
      backgroundColor:Colors.white,
      buttonBackgroundColor: Color.fromARGB(255, 10, 56, 135),
      height: 50,
      index: indexNum,
      items: const [
        Icon(
          Icons.explore,
          size: 30,
          color: Colors.white,
        ),
        Icon(
          Icons.add,
          size: 30,
          color: Colors.white,
        ),
        Icon(
          Icons.person,
          size: 30,
          color: Colors.white,
        ),
      ],
      animationDuration: Duration(
        milliseconds: 300,
      ),
      animationCurve: Curves.bounceInOut,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => TripScreen()));
        } else if (index == 1) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => AddTrip()));
        } 
        else if (index == 2) {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          final User? user = _auth.currentUser;
          final String uid = user!.uid;
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => ProfileScreen(userID:  uid,)));
        } 
      },
    );
  }
}
