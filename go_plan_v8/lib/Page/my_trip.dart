import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_plan_v8/Page/profile.dart';
import 'package:go_plan_v8/Widgets/bottom_nav_bar.dart';
import 'package:uuid/uuid.dart';

import '../Widgets/trip_widget.dart';

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({Key? key}) : super(key: key);

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen> {
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
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Text(
            "ทริปของฉัน",
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
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .where('uploadedBy', isEqualTo: _uid)
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
                      totalCost: snapshot.data?.docs[index]['totalCost'],
                      isPublic: snapshot.data?.docs[index]['isPublic'],
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
