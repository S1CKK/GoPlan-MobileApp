import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_plan_v8/Services/global_methods.dart';
import 'package:go_plan_v8/Services/global_variables.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  final TextEditingController _fullNameController =
      TextEditingController(text: '');
  final TextEditingController _emailTextController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextController =
      TextEditingController(text: '');


  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();


  final _signUpFormKey = GlobalKey<FormState>();
  bool _obscureText = false;// เดิม true
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? imageUrl;

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();
    super.initState();
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
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        'กล้อง',
                        style: TextStyle(
                            color: Colors.purple, fontFamily: 'Kanit'),
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
                    children: const[
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        'แกลอรี',
                        style: TextStyle(
                            color: Colors.purple, fontFamily: 'Kanit'),
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
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery
        ,imageQuality: 50);
  _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 200, maxWidth: 200); // เดิม 1080x1080

        if(croppedImage != null){
          setState(() {
            imageFile = File(croppedImage.path);
          });
        }
  }

void _submitFormOnSignUp() async{
  final isValid = _signUpFormKey.currentState!.validate();
  if(isValid){
    if(imageFile == null){
      GlobalMethod.showErrorDialog(error: "โปรดเลือกรูปภาพ", ctx: context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try{
      await _auth.createUserWithEmailAndPassword(email: _emailTextController.text.trim(), 
      password: _passwordTextController.text.trim());
      final User? user = _auth.currentUser;
      final _uid = user!.uid;
      final ref = FirebaseStorage.instance.ref().child('userImages').child(_uid + '.jpg');
      await ref.putFile(imageFile!);
      imageUrl = await ref.getDownloadURL();
      FirebaseFirestore.instance.collection('users').doc(_uid).set({
        'id': _uid,
        'name': _fullNameController.text,
        'email': _emailTextController.text,
        'userImage': imageUrl,
        'createdAt' : Timestamp.now(),
      });
      Navigator.canPop(context) ? Navigator.pop(context) : null;

    }catch (error){
      setState(() {
        _isLoading = false;
      }
      );
      if(error.toString() == "[firebase_auth/email-already-in-use] The email address is already in use by another account."){
        GlobalMethod.showErrorDialog(error: "Email นี้มีบัญชีผู้ใช้อยู่แล้ว \nโปรดทำการสมัครด้วย Email ใหม่", ctx: context);
      }
       else{
        GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
       }
      print("error occurred $error");
    }
  }
  setState(() {
        _isLoading = false;
      }
      );
}
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: loginUrlImage,
            placeholder: (context, url) => Image.asset(
              'assets/images/goplan_logo_white.png',
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Container(
            color: Colors.black38,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 80),
              child: ListView(
                children: [
                  Form(
                      key: _signUpFormKey,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _showImaegDialog();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Container(
                                width: size.width * 0.24,
                                height: size.width * 0.24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.cyanAccent,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageFile == null
                                      ? const Icon(
                                          Icons.camera_enhance_sharp,
                                          color: Colors.cyan,
                                          size: 30,
                                        )
                                      : Image.file(imageFile!,
                                          fit: BoxFit.fill),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_emailFocusNode),
                            keyboardType: TextInputType.name,
                            controller: _fullNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'โปรดกรอก ชื่อ';
                              } else {
                                return null;
                              }
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: 'Username',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontFamily: 'Kanit'),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                )),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_passFocusNode),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailTextController,
                            validator: (value) {
                              if (value!.isEmpty || !value.contains('@')) {
                                return 'โปรดกรอก Email';
                              } else {
                                return null;
                              }
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontFamily: 'Kanit'),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                errorBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                )),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_passFocusNode),
                            keyboardType: TextInputType.visiblePassword,
                            controller: _passwordTextController,
                            obscureText: !_obscureText,
                            validator: (value) {
                              if (value!.isEmpty || value.length < 6) {
                                return 'โปรดกรอก Password ให้ถูกต้อง';
                              } else {
                                return null;
                              }
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                  child: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                                ),
                                hintText: 'Password',
                                hintStyle: const TextStyle(
                                    color: Colors.white, fontFamily: 'Kanit'),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                errorBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                )),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          _isLoading
                              ? Center(
                                  child: Container(
                                    child: const CircularProgressIndicator(),
                                  ),
                                )
                              : MaterialButton(
                                  onPressed: () {
                                    _submitFormOnSignUp();
                                  },
                                  color: Colors.blue,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'สมัครสมาชิก',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Kanit',
                                              fontSize: 20),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(
                            height: 40,
                          ),
                          Center(
                            child: RichText(
                              text: TextSpan(children: [
                                const TextSpan(
                                    text: 'ฉันมีบัญชีอยู่แล้ว',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Kanit',
                                    )),
                                const TextSpan(text: '       '),
                                TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.canPop(context)
                                          ? Navigator.pop(context)
                                          : null,
                                    text: 'เข้าสู่ระบบ',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: 'Kanit',
                                    )),
                              ]),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
