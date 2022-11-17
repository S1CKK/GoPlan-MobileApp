import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_plan_v8/Services/global_methods.dart';
import 'package:go_plan_v8/Services/global_variables.dart';
import 'package:go_plan_v8/Trip/add_trip_descrb.dart';
import 'package:go_plan_v8/Trip/add_trip_descrb_edit.dart';
import 'package:go_plan_v8/Trip/trip_screen.dart';
import 'package:go_plan_v8/Widgets/bottom_nav_bar.dart';
import 'package:go_plan_v8/Widgets/button.dart';
import 'package:go_plan_v8/Widgets/input_detail.dart';
import 'package:go_plan_v8/Widgets/input_field.dart';
import 'package:get/get.dart';
import 'package:go_plan_v8/Widgets/number_input.dart';
import 'package:google_place/google_place.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddTaskPage extends StatefulWidget {
  final String tripId;
  final String tripTitle;

  final String startDate;
  final String endDate;
  final String dateRan;

  AddTaskPage({
    required this.tripId,
    required this.tripTitle,
    required this.startDate,
    required this.endDate,
    required this.dateRan,
  });

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _taskDetailController = TextEditingController();
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskLocationController = TextEditingController();
  final TextEditingController _taskCostController =
      TextEditingController(text: "0");
  double? latitute=14.8817715;
  double? longtitute=102.0185075;
  int? count = 1;
  DetailsResult? locationPosition;
  late FocusNode locationFocusNode;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _debounce;
  int? tt;
  int? total;
  String? _selectedDay = "Day 1";
  TimeOfDay taskTime = TimeOfDay(hour: 09, minute: 00);
  List<String> dayList = [];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  String? tripTitles;
  File? imageFile;
  String? taskImageUrl;


  void _showImaegDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'โปรดเลือกรูปแบบที่ต้องการ',
              style: TextStyle(fontFamily: 'Kanit'),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: Color.fromARGB(255, 10, 56, 135),
                        ),
                      ),
                      Text(
                        'กล้อง',
                        style: TextStyle(
                            color: Color.fromARGB(255, 10, 56, 135),
                            fontFamily: 'Kanit'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _getFromGallery();
                  },
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Color.fromARGB(255, 10, 56, 135),
                        ),
                      ),
                      Text(
                        'แกลอรี',
                        style: TextStyle(
                            color: Color.fromARGB(255, 10, 56, 135),
                            fontFamily: 'Kanit'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _getFromCamera() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromGallery() async {
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    _cropImage(pickedFile!.path);
    print("PIck  "+pickedFile.path.toString());
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 380,
        maxWidth: 380); // เดิม 1080 x 1080

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }else{
      Navigator.pop(context);
    }
  }

  void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = userDoc.get('name');
      userImage = userDoc.get('userImage');
    });
    final DocumentSnapshot tripDatabase =
        await FirebaseFirestore.instance.collection('trips').doc(trip).get();
    if (tripDatabase == null) {
      return;
    } else {
      setState(() {
        total = tripDatabase.get('totalCost');
        tripTitles = tripDatabase.get('tripTitle');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
    String apiKey = 'AIzaSyBn-kavFpA9sePTBsa4TAdYZrAYc0xVGUg';
    googlePlace = GooglePlace(apiKey);
    locationFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locationFocusNode.dispose();
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final hours = taskTime.hour.toString().padLeft(2, '0');
    final minutes = taskTime.minute.toString().padLeft(2, '0');

    for (var i = 1; i <= int.parse(widget.dateRan); i++) {
      if (dayList.length < int.parse(widget.dateRan)) {
        dayList.add('Day ' + i.toString());
      }
    }

    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 10, 56, 135),
          Color.fromARGB(255, 105, 179, 239),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.2, 0.9],
      )),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(),
        body: Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tripTitles.toString(),
                  style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                MyInputField(
                  title: "วันที่",
                  hint: "$_selectedDay",
                  widget: DropdownButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                    iconSize: 32,
                    elevation: 4,
                    style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                    underline: Container(height: 0), // remove underline
                    items:
                        dayList.map<DropdownMenuItem<String>>((String? value) {
                      return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value!,
                              style: TextStyle(color: Colors.black)));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDay = newValue!;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                MyInputField(
                    title: "เวลา",
                    hint: "${hours}:${minutes}" + " น.",
                    widget: IconButton(
                      onPressed: () async {
                        TimeOfDay? newTime = await showTimePicker(
                            context: context, initialTime: taskTime);

                        //if 'cancel' => null
                        if (newTime == null) return;
                        //if 'ok' => TimeOfDay
                        setState(() {
                          taskTime = newTime;
                        });
                      },
                      icon: Icon(
                        Icons.access_time_rounded,
                        color: Colors.black,
                      ),
                    )
                    // controller: _taskTimeController
                    ),
                MyInputField(
                    title: "หัวข้อ",
                    hint: "โปรดกรอกชื่อหัวข้อ",
                    controller: _taskTitleController
                    ),
                MyInputDetail(
                    title: "รายละเอียด",
                    hint: "โปรดกรอกรายละเอียด",
                    controller: _taskDetailController),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "ภาพประกอบ",
                  style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    child: GestureDetector(
                      onTap: () {
                        _showImaegDialog();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          width: size.width * 0.7,
                          height: size.width * 0.5,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: imageFile == null
                                ? const Icon(
                                    Icons.add_photo_alternate,
                                    color: Color.fromARGB(255, 10, 56, 135),
                                    size: 100,
                                  )
                                : Image.file(imageFile!, fit: BoxFit.fill),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "สถานที่",
                  style: TextStyle(
                      fontFamily: 'Kanit',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black),
                ),
                Container(
                  height: 52,
                  margin: EdgeInsets.only(top:8),
                  padding: EdgeInsets.only(left: 14),
                  decoration: BoxDecoration(border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: 
                      TextFormField(
                        cursorColor: Get.isDarkMode?Colors.grey[100]:Colors.grey[700],
                  controller: _taskLocationController,
                  autofocus: false,
                  focusNode: locationFocusNode,
                  style: TextStyle(fontSize: 15,fontFamily: 'Kanit',fontWeight: FontWeight.bold,color: Colors.black),

                  decoration: InputDecoration(
                      hintText: 'โปรดระบุสถานที่',
                      hintStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15,color: Colors.black),
                      border: InputBorder.none,
                      suffixIcon: _taskLocationController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  predictions = [];
                                  _taskLocationController.clear();
                                  count = 1;
                                });
                              },
                              icon: Icon(Icons.clear_outlined),
                            )
                          : null),
                  onChanged: (value) async {
                    if (value.isEmpty) {
                      setState(() {
                        count = 1;
                      });
                    }
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      if (value.isNotEmpty && count == 1) {
                        //places api
                        autoCompleteSearch(value);
                      } else {
                        //clear out the results
                        setState(() {
                          predictions = [];
                          locationPosition = null;
                        });
                      }
                    });
                  },
                ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
               
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.pin_drop,
                                color: Color.fromARGB(255, 10, 56, 135),
                              ),
                            ),
                            title: Text(
                              predictions[index].description.toString(),
                            ),
                            onTap: () async {
                              final placeId = predictions[index].placeId!;
                              final details =
                                  await googlePlace.details.get(placeId);
                              if (details != null &&
                                  details.result != null &&
                                  mounted) {
                                setState(() {
                                  locationPosition = details.result;
                                  latitute = locationPosition!.geometry!.location!.lat;
                                  longtitute = locationPosition!.geometry!.location!.lng;
                                  _taskLocationController.text =
                                      details.result!.name!;
                                  predictions = [];
                                });
                                count = 0;
                                print("location is  " + details.result!.name!);
                                print("detail  "+ _taskLocationController.text);
                              }
                            },
                          );
                        }),
                  ),
             
                MyInputNumber(
                  title: "ค่าใช้จ่าย",
                  hint: "0",
                  controller: _taskCostController,
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Padding(padding: const EdgeInsets.only(bottom: 30),
                  child: _isLoading ? 
                  const CircularProgressIndicator()
                  : MyButton(label: "บันทึกกิจกรรม", onTap: () => _validateData()),),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _validateData() {
    if (_taskCostController.text.isEmpty) {
      setState(() {
        _taskCostController.text == "0";
      });
    }
    if(_taskTitleController.text.length > 25){
       GlobalMethod.showErrorDialog(
          error: "               ความยาวของหัวข้อ\n           ไม่ควรเกิน 25 ตัวอักษร", ctx: context);
    }
    else if (_taskCostController.text.contains(' ') ||
    _taskCostController.text.contains('-') || 
     _taskCostController.text.contains('.') ||
    _taskCostController.text.contains(',')  ){
        GlobalMethod.showErrorDialog(
          error: "              กรุณากรอกค่าใช้จ่าย\n                เป็นจำนวนเต็มบวก", ctx: context);
    }
    else if (_taskTitleController.text.isNotEmpty &&
        _taskDetailController.text.isNotEmpty &&
        _taskLocationController.text.isNotEmpty) {
      _addTaskToDb();
      
    } else if (_taskTitleController.text.isEmpty ||
        _taskDetailController.text.isEmpty ||
        _taskLocationController.text.isEmpty) {
      GlobalMethod.showErrorDialog(
          error: "กรุณากรอกข้อมูลให้ครบถ้วน", ctx: context);
    } else {
      GlobalMethod.showErrorDialog(
          error: "กรุณากรอกข้อมูลให้ครบถ้วน", ctx: context);
    }
  }

  _addTaskToDb() async {
    final taskId = const Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;

    if ((_taskTitleController.text.isEmpty ||
        _taskDetailController.text.isEmpty ||
        _taskLocationController.text.isEmpty)) {
      GlobalMethod.showErrorDialog(
          error: "กรุณากรอกข้อมูลให้ครบถ้วน", ctx: context);
      return;
    }
    setState(() {
      _isLoading = true;
      tt = (total! + int.parse(_taskCostController.text));
    });
    try {
      final _tid = taskId;
      final ref = FirebaseStorage.instance
          .ref()
          .child('taskImages')
          .child(_tid + '.jpg');
      await ref.putFile(imageFile!);
      taskImageUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection("trips")
          .doc(trip)
          .collection(_selectedDay.toString())
          .doc(taskId)
          .set({
        'day': _selectedDay,
        'taskId': taskId,
        'title': _taskTitleController.text,
        'time': taskTime.to24hours().toString(), // + " น."
        'cost': int.parse(_taskCostController.text),
        'location': _taskLocationController.text,
        'location_lat': latitute,
        'location_lng': longtitute,
        'detail': _taskDetailController.text,
        'uploadedBy': _uid,
        'tripId': widget.tripId,
        'taskImageUrl': taskImageUrl,

      });
      await FirebaseFirestore.instance.collection("trips").doc(trip).update({
        'totalCost': tt,
      });
      await Fluttertoast.showToast(
          msg: "บันทึกกิจกรรมเรียบร้อย",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0);
      _taskCostController.clear();
      _taskDetailController.clear();
      _taskLocationController.clear();

      _taskTitleController.clear();
      setState(() {
        _selectedDay = "Day 1";
        taskTime = TimeOfDay(hour: 09, minute: 00);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AddTripDesEdit(
                      tripId: widget.tripId,
                      tripTitle: widget.tripTitle,
                      startDate: widget.startDate,
                      endDate: widget.endDate,
                      dateRan: widget.dateRan,
                    )));
      });
    } catch (error) {
      {
        setState(() {
          _isLoading = false;
        });
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
          onPressed: () {
            // Get.back();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (c) => TripScreen()));
          },
          icon: const Icon(Icons.arrow_back_ios,
              color: Color.fromARGB(255, 10, 56, 135))),
      actions: [
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}

extension TimeOfDayConverter on TimeOfDay {
  String to24hours() {
    final hour = this.hour.toString().padLeft(2, "0");
    final min = this.minute.toString().padLeft(2, "0");
    return "$hour:$min";
  }
}
