import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_plan_v8/Services/global_variables.dart';
import 'package:go_plan_v8/Task/add_task_page.dart';
import 'package:go_plan_v8/Trip/add_trip_edit.dart';
import 'package:go_plan_v8/Trip/trip_details.dart';
import 'package:go_plan_v8/Trip/trip_screen.dart';
import 'package:go_plan_v8/Widgets/button.dart';
import 'package:go_plan_v8/Widgets/task_widget.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class AddTripDesEdit extends StatefulWidget {
  final String tripId;
  final String tripTitle;
  final String startDate;
  final String endDate;
  final String dateRan;

  AddTripDesEdit({
    required this.tripId,
    required this.tripTitle,
    required this.startDate,
    required this.endDate,
    required this.dateRan,
  });

  @override
  State<AddTripDesEdit> createState() => _AddTripDesEditState();
}

class _AddTripDesEditState extends State<AddTripDesEdit> {
  bool? isPublic;
  String? tripIds;
  String? tripTitles;
  int? dateRanges;
  String? startDates;
  String? endDates;
  String? tripImage;
  int? totalCost;

  void getMyData() async {
    final DocumentSnapshot tripDatabase =
        await FirebaseFirestore.instance.collection('trips').doc(trip).get();
    if (tripDatabase == null) {
      return;
    } else {
      setState(() {
        isPublic = tripDatabase.get('isPublic');
        tripIds = tripDatabase.get('tripId');
        tripTitles = tripDatabase.get('tripTitle');
        startDates = tripDatabase.get('startDate');
        endDates = tripDatabase.get('endDate');
        dateRanges = tripDatabase.get('dateRange');
        tripImage = tripDatabase.get('tripImage');
        totalCost = tripDatabase.get('totalCost');
      });
    }
  }

  String _selectedDate = "Day 1";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(isPublic),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tripTitles.toString(),
                      style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 10, 56, 135)),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          tripNameEdit = tripTitles.toString();
                          startDateEdit = startDates.toString();
                          endDateEdit = endDates.toString();
                          tripImageEdit = tripImage;
                          splitted1 = startDateEdit!.split('/');
                          splitted2 = endDateEdit!.split('/');
                          // print("test === "+widget.endDate.toString());
                        });
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddTripEdit(
                                    tripIdEdit: widget.tripId,
                                    tripTitle: widget.tripTitle,
                                    startDate: widget.startDate,
                                    endDate: widget.endDate,
                                    dateRan: dateRanges.toString())));
                      },
                      icon: Icon(Icons.create),
                      color: Colors.blueGrey,
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  startDates.toString() + '   →   ' + endDates.toString(),
                  style: const TextStyle(
                      fontFamily: 'Kanit', fontSize: 15, color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                ),
                
                Container(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            itemCount: dateRanges,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate =
                                      "Day " + (index + 1).toString();
                                  print("tapped day${index + 1}");
                                });
                              },
                              child: Container(
                                height: 80,
                                width: 80,
                                margin: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Day ${index + 1}",
                                    style: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromARGB(255, 10, 56, 135)),
                                  ),
                                ),
                                color: Color.fromARGB(255, 221, 229, 255),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "แผนของทริปใน " + _selectedDate,
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Kanit',
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    _addTaskIcon(),
                  ],
                ),
                _showTasks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _addTaskIcon() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(left: 50, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
            MyButton(
                label: "เพิ่มกิจกรรม",
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddTaskPage(
                                tripId: widget.tripId,
                                tripTitle: widget.tripTitle,
                                startDate: widget.startDate,
                                endDate: widget.endDate,
                                dateRan: widget.dateRan,
                              )));
                }),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  _showTasks() {
    setState(() {
                  stDate = widget.startDate;
                  eDate = widget.endDate;
                  dRan = widget.dateRan;
                  totalCosts = totalCost;
                });
    return Container(
      child: Container(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("trips")
              .doc(trip)
              .collection(_selectedDate)
              // .where('day', isEqualTo: "Day 1")
              .orderBy('time', descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data?.docs.isNotEmpty == true) {
                return Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return TaskWidget(
                        tripId: snapshot.data?.docs[index]['tripId'],
                        uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                        taskId: snapshot.data?.docs[index]['taskId'],
                        day: snapshot.data?.docs[index]['day'],
                        taskTitle: snapshot.data?.docs[index]['title'],
                        time: snapshot.data?.docs[index]['time'],
                        taskCost: snapshot.data?.docs[index]['cost'],
                        taskLocation: snapshot.data?.docs[index]['location'],
                        location_lat: snapshot.data?.docs[index]
                            ['location_lat'],
                        location_lng: snapshot.data?.docs[index]
                            ['location_lng'],
                        taskDetail: snapshot.data?.docs[index]['detail'],
                        taskImageUrl: snapshot.data?.docs[index]
                            ['taskImageUrl'],
                      );
                    },
                  ),
                );
              } else {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 180),
                    child: Text(
                      "ไม่มีกำหนดการ",
                      style: TextStyle(
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(255, 10, 56, 135)),
                    ),
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

  _appBar(bool? isPublic) {

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              )),
              builder: (context) => Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          // ทำแถบ
                          height: 6,
                          width: 60,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blueGrey),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "ใครสามารถเห็นทริปนี้ได้บ้าง ?",
                          style: TextStyle(
                              fontFamily: 'Kanit',
                              color: Colors.black,
                              fontSize: 20),
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                getMyData();
                                FirebaseFirestore.instance
                                    .collection("trips")
                                    .doc(trip)
                                    .update({
                                  'isPublic': true,
                                });
                                isPublic = true;
                              });

                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, top: 15),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.public,
                                    color: Color.fromARGB(255, 10, 56, 135),
                                  ),
                                  Text(
                                    "    สาธารณะ",
                                    style: TextStyle(
                                        fontFamily: 'Kanit',
                                        color: Colors.black,
                                        fontSize: 18),
                                  )
                                ],
                              ),
                            )),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                getMyData();
                                FirebaseFirestore.instance
                                    .collection("trips")
                                    .doc(trip)
                                    .update({
                                  'isPublic': false,
                                });
                                isPublic = false;
                              });

                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, top: 15),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock,
                                    color: Color.fromARGB(255, 10, 56, 135),
                                  ),
                                  Text(
                                    "    เฉพาะฉัน",
                                    style: TextStyle(
                                        fontFamily: 'Kanit',
                                        color: Colors.black,
                                        fontSize: 18),
                                  )
                                ],
                              ),
                            )),
                      ],
                    ),
                  ));
        },
        icon: Icon(
          isPublic == true ? Icons.public : Icons.lock,
          color: Colors.black,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 1, top: 8),
          child: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const TripScreen()));
              Fluttertoast.showToast(
                msg: "บันทึกทริปเรียบร้อยแล้ว",
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: Colors.grey,
                fontSize: 18,
              );
            },
            child: Container(
              width: 80,
              height: 5,
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  "โพสต์",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(255, 10, 56, 135),
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
