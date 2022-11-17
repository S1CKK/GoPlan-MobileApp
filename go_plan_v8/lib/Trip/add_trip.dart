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
import 'package:go_plan_v8/main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddTrip extends StatefulWidget {
  const AddTrip({Key? key}) : super(key: key);

  @override
  State<AddTrip> createState() => _AddTripState();
}

class _AddTripState extends State<AddTrip> {
  final TextEditingController _tripTopicController = TextEditingController();
  final TextEditingController _startDateController =
      TextEditingController(text: "วันเริ่มต้นการเดินทาง");
  final TextEditingController _endDateController =
      TextEditingController(text: "วันสิ้นสุดการเดินทาง");
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  DateTime? picked;
  Timestamp? strartDateTimeStamp;
  DateTimeRange dateRange =
      DateTimeRange(start: DateTime(2022, 1, 1), end: DateTime(2022, 12, 12));
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? tripImageUrl;

  @override
  void dispose() {
    super.dispose();
    _tripTopicController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
  }

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
    }
  }

  Widget _textTitles({required String label}) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _textFormFields({
    required String valueKey,
    required TextEditingController controller,
    required bool enabled,
    required Function fct,
    required int maxLength,
  }) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'ไม่มีการระบุข้อมูล';
            }
            return null;
          },
          controller: controller,
          enabled: enabled,
          key: ValueKey(valueKey),
          style: const TextStyle(color: Colors.black, fontFamily: 'Kanit'),
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.black12,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadTask() async {
    final tripId = const Uuid().v4();
    User? user = FirebaseAuth.instance.currentUser;
    final _uid = user!.uid;
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      print("status : --> valid");
      if ((_startDateController.text == 'วันเริ่มต้นการเดินทาง' ||
          _endDateController.text == 'วันสิ้นสุดการเดินทาง' ||
          imageFile == null ||
          _tripTopicController.text == "")) {
        GlobalMethod.showErrorDialog(
            error: "กรุณากรอกข้อมูลให้ครบถ้วน", ctx: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        final _tid = tripId;
        trip = tripId;
        final ref = FirebaseStorage.instance
            .ref()
            .child('tripImages')
            .child(_tid + '.jpg');
        await ref.putFile(imageFile!);
        tripImageUrl = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('trips').doc(tripId).set({
          'tripId': tripId,
          'uploadedBy': _uid,
          'email': user.email,
          'tripTitle': _tripTopicController.text,
          'startDate': _startDateController.text,
          'endDate': _endDateController.text,
          // 'favorite': false,
          'createAt': Timestamp.now(),
          'name': name,
          'userImage': userImage,
          'isPublic': true,
          'likes': 0,
          'userLike': Map(),
          'totalCost': 0,
          'tripImage': tripImageUrl,
          'dateRange': (dateRange.duration.inDays + 1),
        });
        await Fluttertoast.showToast(
            msg: "บันทึกทริปเรียบร้อยแล้ว",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.grey,
            fontSize: 18.0);
        _tripTopicController.clear();
        setState(() {
          _startDateController.text = "วันเริ่มต้นการเดินทาง";
          _endDateController.text = "วันสิ้นสุดการเดินทาง";

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AddTripDesEdit(
                tripId: trip.toString(),
                tripTitle: _tripTopicController.text,
                startDate: _startDateController.text,
                endDate: _endDateController.text,
                dateRan: (dateRange.duration.inDays + 1).toString(),
              ),
            ),
          );
        });
      } catch (error) {
        {
          setState(() {
            _isLoading = false;
          });
          GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
          print(error.toString());
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
    print("status : --> not valid");
    setState(() {
      _isLoading = false;
    });
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(
          indexNum: 1,
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Image.asset(
            "assets/images/new_logo.png",
            fit: BoxFit.contain,
            height: 32,
          ),
          // centerTitle: true,
          backgroundColor: Color.fromARGB(255, 10, 56, 135),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(7.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _textTitles(label: 'ชื่อทริป :'),
                            _textFormFields(
                              valueKey: 'ชื่อทริป',
                              controller: _tripTopicController,
                              enabled: true,
                              fct: () {},
                              maxLength: 20,
                            ),
                            _textTitles(label: 'ภาพประกอบ :'),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 2),
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
                                          color:
                                              Color.fromARGB(255, 10, 56, 135),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: imageFile == null
                                            ? const Icon(
                                                Icons.add_photo_alternate,
                                                color: Color.fromARGB(
                                                    255, 10, 56, 135),
                                                size: 100,
                                              )
                                            : Image.file(imageFile!,
                                                fit: BoxFit.fill),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _textTitles(label: "วันเริ่มต้น :"),
                            _textFormFields(
                                valueKey: "วันเริ่มต้น",
                                controller: _startDateController,
                                enabled: false,
                                fct: () {
                                  pickDateRange();
                                },
                                maxLength: 100),
                            _textTitles(label: "วันสิ้นสุด :"),
                            _textFormFields(
                                valueKey: "วันสิ้นสุด",
                                controller: _endDateController,
                                enabled: false,
                                fct: () {},
                                maxLength: 100)
                          ],
                        )),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : MaterialButton(
                              onPressed: () async {
                                await _uploadTask();

                                if (_isLoading == true) {
                                  // await Navigator.pushReplacement(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //   builder: (context) => AddTripDes(
                                  //     tripId: trip.toString(),
                                  //     tripTitle: _tripTopicController.text,
                                  //     startDate: _startDateController.text,
                                  //     endDate: _endDateController.text,
                                  //     dateRan: (dateRange.duration.inDays+1).toString(),),
                                  //     ),
                                  //     );
                                }
                              },
                              color: Color.fromARGB(255, 10, 56, 135),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "สร้างทริป",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Kanit',
                                          fontSize: 20),
                                    ),
                                    SizedBox(
                                      width: 9,
                                    ),
                                    Icon(
                                      Icons.upload_file,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
        context: context,
        initialDateRange: dateRange,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        builder: (context, child) => SingleChildScrollView(
              child: Column(
                children: [
                  Theme(
                    data: ThemeData().copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        surface: Colors.blueAccent,
                        onSurface: Colors.white,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child ?? Text(""),
                  ),
                ],
              ),
            ));

    if (newDateRange == null) return; // กด X
    setState(() {
      dateRange = newDateRange; // กด save
      _startDateController.text =
          '${dateRange.start.day} / ${dateRange.start.month} / ${dateRange.start.year}';
      _endDateController.text =
          '${dateRange.end.day} / ${dateRange.end.month} / ${dateRange.end.year}';
    });
  }
}
