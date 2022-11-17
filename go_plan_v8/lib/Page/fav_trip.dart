import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_plan_v8/Page/profile.dart';
import 'package:go_plan_v8/Trip/trip_screen.dart';
import 'package:go_plan_v8/Widgets/bottom_nav_bar.dart';

import '../Widgets/trip_widget.dart';

class FavTripScreen extends StatefulWidget {
  const FavTripScreen({Key? key}) : super(key: key);

  @override
  State<FavTripScreen> createState() => _FavTripScreenState();
}

class _FavTripScreenState extends State<FavTripScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final _uid = user!.uid;
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "ทริปที่ชอบ",
            style: TextStyle(
                color: Color.fromARGB(255, 10, 56, 135),
                fontFamily: 'Kanit',
                fontSize: 25,
                fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 30,
              color: Color.fromARGB(255, 10, 56, 135),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(userID: _uid)));
            },
          ),

          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .where('userLike.$_uid', isEqualTo: true)
              // .where('recruitment', isEqualTo: true)
              // .orderBy('createAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data?.docs.isNotEmpty == true) {
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TripWidget(
                      tripTitle: snapshot.data?.docs[index]['tripTitle'],
                      tripId: snapshot.data?.docs[index]['tripId'],
                      uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                      userImage: snapshot.data?.docs[index]['userImage'],
                      name: snapshot.data?.docs[index]['name'],
                      isPublic: snapshot.data?.docs[index]['isPublic'],
                      totalCost: snapshot.data?.docs[index]['totalCost'],
                      email: snapshot.data?.docs[index]['email'],
                      startDate: snapshot.data?.docs[index]['startDate'],
                      endDate: snapshot.data?.docs[index]['endDate'],
                      tripImage: snapshot.data?.docs[index]['tripImage'],
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    "ไม่มีทริป",
                    style: TextStyle(
                        fontFamily: 'Kanit',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromARGB(255, 10, 56, 135)),
                  ),
                );
              }
            }
            return const Center(
              child: Text(
                "มีบางอย่างผิดพลาด",
                style: TextStyle(
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            );
          },
        ),
      ),
    );
  }
}
