import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_plan_v8/Services/global_methods.dart';
import 'package:go_plan_v8/Services/global_variables.dart';
import 'package:go_plan_v8/Trip/add_trip_descrb.dart';
import 'package:go_plan_v8/Trip/add_trip_descrb_edit.dart';
import 'package:go_plan_v8/Trip/trip_screen.dart';
import 'package:go_plan_v8/Widgets/task_show_widget.dart';
import 'package:go_plan_v8/Widgets/task_widget.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TripDetailsScreen extends StatefulWidget {
  final String uploadedBy;
  final String tripID;
  final String startDate;
  final String endDate;

  TripDetailsScreen({
    required this.uploadedBy,
    required this.tripID,
    required this.startDate,
    required this.endDate,
  });
  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedDate = "Day 1";
  bool click = true;
  bool cl = true;
  String? authorName;
  String? userImageUrl;
  String? tripTitle;
  int? dateRange;
  // bool? favorite;
  Timestamp? postedDateTimeStamp;
  Timestamp? startDateTimeStamp;
  Timestamp? endDateTimeStamp;
  String? postedDate;
  String? startDate;
  String? endDate;
  int? likes;
  Map? userLike;
  bool? isLiked;
  bool? isPublic;
  int? totalCost;

  void getTripData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uploadedBy)
        .get();

    if (userDoc == null) {
      return;
    } else {
      setState(() {
        authorName = userDoc.get('name');
        userImageUrl = userDoc.get('userImage');
      });
    }
    final DocumentSnapshot tripDatabase = await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripID)
        .get();
    if (tripDatabase == null) {
      return;
    } else {
      setState(() {
        likes = tripDatabase.get('likes');
        tripTitle = tripDatabase.get('tripTitle');
        // favorite = tripDatabase.get('favorite');
        userLike = tripDatabase.get('userLike');
        isPublic = tripDatabase.get('isPublic');
        startDate = tripDatabase.get('startDate');
        endDate = tripDatabase.get('endDate');
        postedDateTimeStamp = tripDatabase.get('createAt');
        dateRange = tripDatabase.get('dateRange');
        totalCost = tripDatabase.get('totalCost');
        var postDate = postedDateTimeStamp!.toDate();
        postedDate = '${postDate.day}-${postDate.month}-${postDate.year}';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTripData();
  }

  Widget dividerWidget() {
    return Column(
      children: const [
        SizedBox(
          height: 10,
        ),
        Divider(
          thickness: 1,
          color: Color.fromARGB(255, 10, 56, 135),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final _uid = user!.uid;
    if (userLike != null) {
      isLiked = userLike![_uid] == true;
    }
   NumberFormat myFormat = NumberFormat.decimalPattern('en_us'); // format number to 1,000 
    return Container(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 221, 229, 255),
        appBar: _appBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(4.0),
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    tripTitle == null ? '' : tripTitle!,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 10, 56, 135),
                                      fontFamily: 'Kanit',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                              isPublic == true ? Icons.public : Icons.lock,
                              color: Colors.blueGrey,size: 15,
                            ),
                                ],
                              ),
                              
                              Container(
                                  child: widget.uploadedBy == _uid.toString()
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              trip = widget.tripID;
                                            });
                                            showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                  top: Radius.circular(30),
                                                )),
                                                builder: (context) => Container(
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            // ทำแถบ
                                                            height: 6,
                                                            width: 60,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .blueGrey),
                                                          ),
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => AddTripDesEdit(
                                                                            tripId: widget
                                                                                .tripID,
                                                                            tripTitle:
                                                                                tripTitle!,
                                                                            startDate:
                                                                                widget.startDate,
                                                                            endDate: widget.endDate,
                                                                            dateRan: dateRange.toString())));
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20,
                                                                        top:
                                                                            20),
                                                                child: Row(
                                                                  children: const [
                                                                    Icon(
                                                                      Icons
                                                                          .mode_edit,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          10,
                                                                          56,
                                                                          135),
                                                                    ),
                                                                    Text(
                                                                      "    แก้ไขทริป",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Kanit',
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              18),
                                                                    )
                                                                  ],
                                                                ),
                                                              )),
                                                          
                                                          TextButton(
                                                              // delete trip
                                                              onPressed: () {
                                                                deleteTrip();
                                                              },
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Color.fromARGB(
                                                                          255,
                                                                          10,
                                                                          56,
                                                                          135),
                                                                    ),
                                                                    Text(
                                                                      "    ลบทริป",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Kanit',
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              18),
                                                                    )
                                                                  ],
                                                                ),
                                                              )),
                                                          SizedBox(
                                                            height: 22,
                                                          )
                                                          
                                                        ],
                                                      ),
                                                    ));
                                          },
                                          icon: const Icon(
                                            Icons.more_horiz,
                                            color: Color.fromARGB(
                                                255, 10, 56, 135),
                                          ))
                                      : null
                                      
                                          ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 3,
                                    color: Color.fromARGB(255, 221, 229, 255),
                                  ),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      userImageUrl == null
                                          ? 'https://cdn-icons-png.flaticon.com/512/3899/3899618.png'
                                          : userImageUrl!,
                                    ),
                                    fit: BoxFit.fill,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authorName == null ? '' : authorName!,
                                    style: const TextStyle(
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: handleLikePost,
                                        child: Icon(
                                          isLiked == true
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 20,
                                          color: Colors.pink,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        likes.toString() +
                                            "  คน " +
                                            "ชื่นชอบทริปนี้",
                                        style: const TextStyle(
                                            fontFamily: 'Kanit',
                                            fontSize: 14,
                                            color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        dividerWidget(),
                        const Text(
                          'รายละเอียดทริป',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              '●   ' +
                                  widget.startDate +
                                  '  →  ' +
                                  widget.endDate +
                                  '\n●   ระยะเวลา ' +
                                  dateRange.toString() +
                                  ' วัน'+
                                  '\n●   ค่าใช้จ่ายทั้งหมด ${totalCost}  บาท',
                              style: const TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 14,
                                  color: Colors.black),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            //  _addDateBar(),
                            Container(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 80,
                                      child: ListView.builder(
                                        itemCount: dateRange,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) =>
                                            GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedDate = "Day " +
                                                  (index + 1).toString();
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
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 10, 56, 135)),
                                              ),
                                            ),
                                            color: Color.fromARGB(
                                                255, 221, 229, 255),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        dividerWidget(),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Text(
                                "แผนของทริปใน  ",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Kanit',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _selectedDate,
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily: 'Kanit',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        dividerWidget(),

                        _showTasks(),
                        SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleLikePost() {
    final User? user = _auth.currentUser;
    final _uid = user!.uid;
    bool _isLiked = userLike![_uid] == true;

    if (_isLiked) {
      setState(() {
        likes = likes! - 1;
        isLiked = false;
        userLike![_uid] = false;
      });
      FirebaseFirestore.instance.collection('trips').doc(widget.tripID).update({
        'userLike.$_uid': false,
        'likes': likes,
      });
    } else if (!_isLiked) {
      setState(() {
        likes = likes! + 1;
        isLiked = true;
        userLike![_uid] = true;
      });
      FirebaseFirestore.instance.collection('trips').doc(widget.tripID).update({
        'userLike.$_uid': true,
        'likes': likes,
      });
    }
  }

  deleteTrip() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black87,
            title: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "คุณต้องการลบทริปนี้หรือไม่",
                    style: TextStyle(
                        color: Colors.white, fontSize: 18, fontFamily: 'Kanit'),
                  ),
                )
              ],
            ),
            content: const Padding(
              padding: EdgeInsets.only(left: 30),
              child: const Text(
                "ทริปนี้จะหายไปอย่างถาวร",
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Kanit',
                  fontSize: 18,
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    
                  },
                  child: const Text(
                    "ไม่",
                    style: TextStyle(
                        fontFamily: 'Kanit', color: Colors.red, fontSize: 18),
                  )),
              TextButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('trips')
                        .doc(widget.tripID)
                        .delete();
                    await Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => TripScreen()));
                    await Fluttertoast.showToast(
                      msg: "คุณได้ลบทริปเรียบร้อยแล้ว",
                      toastLength: Toast.LENGTH_LONG,
                      backgroundColor: Colors.grey,
                      fontSize: 18,
                    );
                  },
                  child: const Text(
                    "ใช่",
                    style: TextStyle(
                        fontFamily: 'Kanit', color: Colors.green, fontSize: 18),
                  )),
            ],
          );
        });
  }

  void addUserFav() async {
    final User? user = _auth.currentUser;
    final _uid = user!.uid;
    final favId = const Uuid().v4();
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(widget.tripID)
        .update({
      'favBy': FieldValue.arrayUnion([
        {
          'user': _uid,
        }
      ])
    });
    await Fluttertoast.showToast(
      msg: "คุณถูกใจทริปนี้",
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.grey,
      fontSize: 18,
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Color.fromARGB(255, 221, 229, 255),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          size: 30,
          color: Color.fromARGB(255, 10, 56, 135),
        ),
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const TripScreen()));
        },
      ),
      actions: [
        SizedBox(
          width: 20,
        ),
      ],
    );
  }

  _showTasks() {
    return Column(
      children: [
        Container(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("trips")
                .doc(widget.tripID)
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
                  return SingleChildScrollView(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TaskShowWidget(
                          tripId: snapshot.data?.docs[index]['tripId'],
                          uploadedBy: snapshot.data?.docs[index]['uploadedBy'],
                          taskId: snapshot.data?.docs[index]['taskId'],
                          day: snapshot.data?.docs[index]['day'],
                          taskTitle: snapshot.data?.docs[index]['title'],
                          time: snapshot.data?.docs[index]['time'],
                          taskCost: snapshot.data?.docs[index]['cost'],
                          taskLocation: snapshot.data?.docs[index]['location'],
                          location_lat: snapshot.data?.docs[index]['location_lat'],
                          location_lng: snapshot.data?.docs[index]['location_lng'],
                          taskDetail: snapshot.data?.docs[index]['detail'],
                          taskImageUrl: snapshot.data?.docs[index]['taskImageUrl'],
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
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
      ],
    );
  }
}
