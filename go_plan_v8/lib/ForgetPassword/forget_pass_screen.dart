// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_plan_v8/LoginPage/login_screen.dart';
import 'package:go_plan_v8/Services/global_variables.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword>
    with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _forgetPassTextController =
      TextEditingController(text: '');

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _forgetPassSubmitForm() async {
    try {
      await _auth.sendPasswordResetEmail(
        email: _forgetPassTextController.text,
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Login()));
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: loginUrlImage,
            placeholder: (context, url) => Image.asset(
              'assets/images/wallpaper.jpg',
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value, 0),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                SizedBox(
                  height: size.height * 0.1,
                ),
                const Text(
                  "ลืมรหัสผ่าน",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      fontFamily: 'Kanit'),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Email address",
                  style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Kanit'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _forgetPassTextController,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white60,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      )),
                ),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  onPressed: () {
                    _forgetPassSubmitForm();
                  },
                  color: Colors.blue,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      "เปลี่ยนรหัสผ่าน",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Kanit'),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
