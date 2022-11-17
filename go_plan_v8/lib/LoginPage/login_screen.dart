import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:go_plan_v8/ForgetPassword/forget_pass_screen.dart';
import 'package:go_plan_v8/Services/global_methods.dart';
import 'package:go_plan_v8/Services/global_variables.dart';
import 'package:go_plan_v8/SignUpPage/signup_screen.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{

  late Animation<double> _animation;
  late AnimationController _animationController;

  final TextEditingController _emailTextController = TextEditingController(text: '');
  final TextEditingController _passwordTextController = TextEditingController(text: '');

  final FocusNode _passFocusNode = FocusNode();
  bool _obscureText = false;// เดิม true
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _loginFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _animationController.dispose();
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 20));
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear)
    ..addListener((){
      setState(() {
        
      });
     })
    ..addStatusListener((animationStatus) { 
      if(animationStatus == AnimationStatus.completed){
        _animationController.reset();
        _animationController.forward();
      }
    });
    _animationController.forward();
    super.initState();
  }

  void _submitFormOnLogin() async{
    final isValid = _loginFormKey.currentState!.validate();
    if(isValid){
      setState((){
        _isLoading = true;
      });
      try{
        await _auth.signInWithEmailAndPassword(email: _emailTextController.text.trim(), password: _passwordTextController.text.trim());
        // ignore: use_build_context_synchronously
        Navigator.canPop(context)?Navigator.pop(context) : null;
      }catch(error){
        // setState((){
        //   _isLoading=false;
        // });
        if(error.toString() == "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted."){
          GlobalMethod.showErrorDialog(error: "      ไม่พบบัญชีของท่านในระบบ \nกรุณาตรวจสอบบัญชีใหม่อีกครั้ง", ctx: context);
        }
        else if (error.toString()=="[firebase_auth/wrong-password] The password is invalid or the user does not have a password."){
           GlobalMethod.showErrorDialog(error: "รหัสผ่านไม่ถูกต้อง", ctx: context);
        }
        else if(error.toString()=="[firebase_auth/invalid-email] The email address is badly formatted."){
          GlobalMethod.showErrorDialog(error: "Email address มีรูปแบบที่ไม่ถูกต้อง", ctx: context);
        }
        else{
             GlobalMethod.showErrorDialog(error: error.toString(), ctx: context);
        print("error occurred $error");
        }
        
      }
    }
    setState(() {
      _isLoading = false;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
           CachedNetworkImage(
            imageUrl: loginUrlImage,
            placeholder: (context, url) => Image.asset(
              'assets/images/goplan_logo_white.png',
              fit: BoxFit.fill,
            ),
            errorWidget:  (context,url,error) => const Icon(Icons.error),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: FractionalOffset(_animation.value,0),
            ),
            Container(
              color: Colors.black38,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
                child: ListView(
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 80,right: 80),
                    child: Image.asset('assets/images/goplan_logo_white.png'),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _loginFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () => FocusScope.of(context).requestFocus(_passFocusNode),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailTextController,
                            validator: (value){
                              if(value!.isEmpty || !value.contains('@')){
                                return 'โปรดกรอก Email ให้ถูกต้อง';
                              }
                              else{
                                return null;
                              }
                            },
                            style: TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(color: Colors.white, fontFamily: 'Kanit'),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )
                            ),
                          ),
                          const SizedBox(height: 20,),
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            focusNode: _passFocusNode,
                            keyboardType: TextInputType.visiblePassword,
                            controller: _passwordTextController,
                            obscureText: !_obscureText,
                            validator: (value){
                              if(value!.isEmpty || value.length < 6){
                                return'โปรดกรอกรหัสผ่านให้ถูกต้อง' ;
                              }
                              else{
                                return null;
                              }
                            },
                            style: TextStyle(color: Colors.white,fontFamily: 'Kanit'),
                            decoration:  InputDecoration(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(_obscureText?Icons.visibility:Icons.visibility_off,
                                color: Colors.white,),
                              ),
                              hintText: 'Password',
                              hintStyle: const TextStyle(color: Colors.white, fontFamily: 'Kanit'),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              )
                            ),
                          ),
                          const SizedBox(height: 30,),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> ForgetPassword()));
                              },
                              child: const Text(
                                'ลืมรหัสผ่าน ?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Kanit',
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          MaterialButton(
                            onPressed: _submitFormOnLogin,
                            color: Colors.blueAccent,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'เข้าสู่ระบบ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily: 'Kanit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ),
                          SizedBox(height: 40,),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "ถ้าคุณยังไม่มีบัญชี",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Kanit',
                                    ),
                                  ),
                                  const TextSpan(text: '    '),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                    ..onTap = () => Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUp())),
                                    text: 'สมัครเลย',
                                    style: const TextStyle(color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    fontFamily: 'Kanit'),
                                    
                                  )
                                ]
                              ),
                            ),
                          ),
                        ],
                      ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}