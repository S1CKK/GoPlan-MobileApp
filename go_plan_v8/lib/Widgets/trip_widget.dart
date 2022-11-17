import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_plan_v8/Services/global_methods.dart';
import 'package:go_plan_v8/Services/global_variables.dart';
import 'package:go_plan_v8/Trip/trip_details.dart';
import 'package:intl/intl.dart';

class TripWidget extends StatefulWidget {
  final int totalCost;
  final String tripTitle;
  final String tripId;
  final String uploadedBy;
  final String userImage;
  final String name;
  final String email;
  final String startDate;
  final String endDate;
  final String tripImage;
  final bool isPublic;

  const TripWidget({
    required this.totalCost,
    required this.tripTitle,
    required this.tripId,
    
    required this.uploadedBy,
    required this.userImage,
    required this.name,
    required this.email,
    required this.startDate,
    required this.endDate,
    required this.tripImage,
    required this.isPublic,
  });

  @override
  State<TripWidget> createState() => _TripWidgetState();
}

class _TripWidgetState extends State<TripWidget> {
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
                onPressed: () async {
                  try {
                    if (widget.uploadedBy == _uid) {
                      await FirebaseFirestore.instance
                          .collection('trips')
                          .doc(widget.tripId)
                          .delete();
                      await Fluttertoast.showToast(
                          msg: 'ทริปได้ถูกลบเรียบร้อย',
                          toastLength: Toast.LENGTH_LONG,
                          backgroundColor: Colors.grey,
                          fontSize: 18.0);
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                    } else {
                      GlobalMethod.showErrorDialog(
                          error: 'คุณไม่สามารถลบได้', ctx: ctx);
                    }
                  } catch (error) {
                    GlobalMethod.showErrorDialog(
                        error: 'ทริปนี้ไม่สามารถลบได้', ctx: ctx);
                  } finally {}
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    Text(
                      'Delete',
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NumberFormat myFormat = NumberFormat.decimalPattern('en_us'); // format number to 1,000 
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: Color.fromARGB(255, 221, 229, 255),
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: InkWell(
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TripDetailsScreen(
                          uploadedBy: widget.uploadedBy,
                          tripID: widget.tripId,
                          startDate: widget.startDate,
                          endDate: widget.endDate,
                        )));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                      image: NetworkImage(widget.tripImage), fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(
                                    width: 3,
                                    color: Color.fromARGB(255, 221, 229, 255),
                                  ),
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      widget.userImage == null
                                          ? 'https://cdn-icons-png.flaticon.com/512/3899/3899618.png'
                                          : widget.userImage,
                                    ),
                                    fit: BoxFit.fill,
                                  )),
                            ),
                        SizedBox(width: 13,),
                        Text(
                          widget.tripTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 10, 56, 135),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kanit',
                              fontSize: 18),
                        ),
                        SizedBox(width: 10,),
                        Icon( 
                              widget.isPublic == true ? Icons.public : Icons.lock,
                              color: Colors.blueGrey,size: 18,
                            ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Kanit',
                              fontSize: 15),
                        ),
                        Text(
                           " ${myFormat.format(widget.totalCost)} ฿",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Kanit',
                              fontSize: 18),
                        ),
                      ],
                    ),
                    Text(
                      widget.startDate + '  →  ' + widget.endDate,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.blueGrey,
                          fontFamily: 'Kanit',
                          fontSize: 13),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
