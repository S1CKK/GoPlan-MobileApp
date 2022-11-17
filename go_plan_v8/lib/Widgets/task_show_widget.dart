import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_plan_v8/Services/global_methods.dart';
import 'package:go_plan_v8/Services/global_variables.dart';
import 'package:go_plan_v8/Trip/trip_details.dart';
import 'package:go_plan_v8/Widgets/map_utils.dart';
import 'package:intl/intl.dart';

class TaskShowWidget extends StatefulWidget {
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

  const TaskShowWidget({
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
  State<TaskShowWidget> createState() => _TaskShowWidgetState();
}

class _TaskShowWidgetState extends State<TaskShowWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  @override
  Widget build(BuildContext context) {
    NumberFormat myFormat = NumberFormat.decimalPattern('en_us'); // format number to 1,000 
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      color: Color.fromARGB(255, 206, 229, 255),
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InkWell(
        onTap: () {
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
                            MapUtils.openMap(widget.location_lat, widget.location_lng);
                          },
                          child:  Text(
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
                        const Divider(thickness: 1,color: Colors.blueGrey,),
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
                    SizedBox(height: 10,),
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
