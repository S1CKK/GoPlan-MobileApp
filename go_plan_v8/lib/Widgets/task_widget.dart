import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_plan_v8/Services/global_methods.dart';
import 'package:go_plan_v8/Services/global_variables.dart';
import 'package:go_plan_v8/Task/add_task_page_edit.dart';
import 'package:go_plan_v8/Trip/trip_details.dart';
import 'package:go_plan_v8/Widgets/map_utils.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TaskWidget extends StatefulWidget {
  final String taskId;
  final String day;
  final String taskTitle;
  final String time;
  final int taskCost;
  final String taskLocation;
  final double location_lat;
  final double location_lng;
  final String taskDetail;
  final String uploadedBy;
  final String tripId;
  final String taskImageUrl;

  const TaskWidget({
    required this.taskId,
    required this.day,
    required this.taskTitle,
    required this.time,
    required this.taskCost,
    required this.taskLocation,
    required this.location_lat,
    required this.location_lng,
    required this.taskDetail,
    required this.uploadedBy,
    required this.tripId,
    required this.taskImageUrl,
  });

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _deleteDialog() {
    User? user = _auth.currentUser;
    final _uid = user!.uid;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    taskDetails = widget.taskDetail;
                    taskTitles = widget.taskTitle;
                    taskLocations = widget.taskLocation;
                    taskLat = widget.location_lat;
                    taskLong = widget.location_lng;
                    taskCosts = widget.taskCost;
                    final splitTime = widget.time.split(':');
                    timeHour = int.parse(splitTime[0]);
                    timeMin = int.parse(splitTime[1]);
                    taskImageEdit = widget.taskImageUrl;
                    // print("Time is : --> "+widget.time);
                    
                  });
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddTaskPageEdit(
                                taskId: widget.taskId,
                                taskTitle: widget.taskTitle,
                                taskTime: widget.time,
                                taskLocation: widget.taskLocation,
                                taskCost: widget.taskCost,
                                taskDetail: widget.taskDetail,
                                day: widget.day,
                                tripId: widget.tripId,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.create,
                      color: Colors.blueGrey,
                    ),
                    Text(
                      '   แก้ไขกิจกรรม',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  // try {
                  if (widget.uploadedBy == _uid) {
                    await FirebaseFirestore.instance
                        .collection('trips')
                        .doc(widget.tripId)
                        .update({
                          'totalCost': totalCosts!-widget.taskCost,
                        });
                    await FirebaseFirestore.instance
                        .collection('trips')
                        .doc(widget.tripId)
                        .collection(widget.day)
                        .doc(widget.taskId)
                        .delete();
                    await Fluttertoast.showToast(
                        msg: 'กิจกรรมได้ถูกลบเรียบร้อย',
                        toastLength: Toast.LENGTH_LONG,
                        backgroundColor: Colors.grey,
                        fontSize: 18.0);
                  } else {
                    GlobalMethod.showErrorDialog(
                        error: 'คุณไม่สามารถลบได้', ctx: ctx);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    Text(
                      '   ลบกิจกรรม',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat myFormat =
        NumberFormat.decimalPattern('en_us'); // format number to 1,000
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      color: Color.fromARGB(255, 206, 229, 255),
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: () {
          _deleteDialog();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                image: DecorationImage(
                    image: NetworkImage(widget.taskImageUrl),
                    fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              widget.time + " น.",
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Kanit',
                              ),
                            ),
                            Text(
                              textAlign: TextAlign.left,
                              "${myFormat.format(widget.taskCost)}  ฿",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 18,
                                fontFamily: 'Kanit',
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            MapUtils.openMap(
                                widget.location_lat, widget.location_lng);
                          },
                          child: Text(
                            textAlign: TextAlign.left,
                            "📍 " + widget.taskLocation,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                              fontFamily: 'Kanit',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(
                          thickness: 1,
                          color: Colors.blueGrey,
                        ),
                        Text(
                          widget.taskTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 10, 56, 135),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            fontFamily: 'Kanit',
                          ),
                        ),
                        Text(
                          widget.taskDetail,
                          maxLines: 1000,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'Kanit',
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
