import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_plan_v8/Page/fav_trip.dart';
import 'package:go_plan_v8/Page/my_trip.dart';
import 'package:go_plan_v8/Widgets/bottom_nav_bar.dart';
import 'package:go_plan_v8/user_state.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  const ProfileScreen({required this.userID});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? name;
  String email = '';
  String imageUrl = '';
  bool _isLoading = false;
  bool _isSameUser = false;

  void getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();
      if (userDoc == null) {
        return;
      } else {
        setState(() {
          name = userDoc.get('name');
          email = userDoc.get('email');
          imageUrl = userDoc.get('userImage');
        });
        User? user = _auth.currentUser;
        final _uid = user!.uid;
        setState(() {
          _isSameUser = _uid == widget.userID;
        });
      }
    } catch (error) {
    } finally {
      _isLoading = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  void _logout(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black87,
            title: Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "ออกจากระบบ",
                    style: TextStyle(
                        color: Colors.white, fontSize: 28, fontFamily: 'Kanit'),
                  ),
                )
              ],
            ),
            content: const Text(
              "คุณต้องการออกจากระบบหรือไม่",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Kanit',
                fontSize: 20,
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
                  onPressed: () {
                    _auth.signOut();
                    Navigator.canPop(context) ? Navigator.pop(context) : null;
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => UserState()));
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

  Widget userInfo({required IconData icon, required String content}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.black,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: const TextStyle(
                color: Colors.black, fontFamily: 'Kanit', fontSize: 18),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBarForApp(
          indexNum: 2,
        ),
        backgroundColor: Colors.white,
        body: Center(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Stack(
                        children: [
                          Card(
                            color: Color.fromARGB(255, 221, 229, 255),
                            margin: const EdgeInsets.all(30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 130,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      children: [
                                        Text(
                                          name == null ? 'Name here' : name!,
                                          style: const TextStyle(
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          email,
                                          style: TextStyle(
                                              fontFamily: 'Kanit',
                                              fontSize: 17,
                                              color: Colors.blueGrey),
                                        ),
                                        SizedBox(height: 10,),
                                        const Divider(thickness: 1,color: Colors.blueGrey,),
                                      ],
                                      
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 60, right: 60),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            width: size.width * 0.15,
                                            height: size.height * 0.15,
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 250, 226, 234),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              FavTripScreen()));
                                                },
                                                icon: Icon(
                                                  Icons.favorite,
                                                  color: Colors.pink,
                                                ))),
                                        Container(
                                          width: size.width * 0.15,
                                          height: size.height * 0.15,
                                          decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 228, 204, 252),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            MyTripScreen()));
                                              },
                                              icon: Icon(
                                                Icons.menu_book,
                                                color: Colors.purple,
                                              )),
                                        )
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 60, right: 60),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "ทรืปที่ชอบ",
                                          style: TextStyle(
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "ทริปของฉัน",
                                          style: TextStyle(
                                              fontFamily: 'Kanit',
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    height: 40,
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: MaterialButton(
                                      onPressed: () {
                                        _logout(context);
                                      },
                                      color: Color.fromARGB(255, 10, 56, 135),
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              "ออกจากระบบ",
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
                                              Icons.exit_to_app,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: size.width * 0.4,
                                height: size.width * 0.4,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 0,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        imageUrl == null
                                            ? 'https://cdn-icons-png.flaticon.com/512/3899/3899618.png'
                                            : imageUrl,
                                      ),
                                      fit: BoxFit.fill,
                                    )),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )),
      ),
    );
  }
}
