import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_plan_v8/Widgets/bottom_nav_bar.dart';
import 'package:go_plan_v8/Widgets/trip_widget.dart';
import 'package:go_plan_v8/user_state.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({Key? key}) : super(key: key);

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
   
  @override
  Widget build(BuildContext context) {
     final _uid = user!.uid;
     print("uid is "+_uid);
    return Container(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(indexNum: 0),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Image.asset(
            "assets/images/new_logo.png",
            fit: BoxFit.contain,
            height: 32,
          ),
          
          backgroundColor: Color.fromARGB(255, 10, 56, 135),
          automaticallyImplyLeading: false,
        
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .where('isPublic', isEqualTo: true ) 
              // .where('uploadedBy', isEqualTo: _uid)
              .orderBy('createAt', descending: true)
              
              
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
                        fontSize: 20,color: Color.fromARGB(255, 10, 56, 135)),
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
