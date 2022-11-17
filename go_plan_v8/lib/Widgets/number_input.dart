import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MyInputNumber extends StatelessWidget {

  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;

  const MyInputNumber({Key? key, required this.title, required this.hint, this.controller, this.widget}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,style: TextStyle(fontFamily: 'Kanit',fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
          Container(height: 52,
          margin: EdgeInsets.only(top: 8.0),
          padding: EdgeInsets.only(left: 14),
          decoration: BoxDecoration(border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12)
          ),
          child: Row(children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                readOnly: widget == null?false:true,
                autofocus: false,
            cursorColor: Get.isDarkMode?Colors.grey[100]:Colors.grey[700],
            controller: controller,
            style: TextStyle(fontFamily: 'Kanit',fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontFamily: 'Kanit',fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                color: context.theme.backgroundColor,
                width: 0)),
                enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                color: context.theme.backgroundColor,
                width: 0))
            ),
            ),
            ),
            widget==null?Container():Container(child:widget)
          ],),
          ),

        ],
      ),
    );
  }
}