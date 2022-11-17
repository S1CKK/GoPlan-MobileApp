import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';


class MyButton extends StatelessWidget {
  final String label;
  final Function()? onTap;

  const MyButton({Key? key,required this.label,required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), 
            color:  Color.fromARGB(255, 10, 56, 135)
            ),
    child: Center(
      child: Text(
        textAlign: TextAlign.center,
        label,
        style: TextStyle(color: Colors.white, fontFamily: 'Kanit', fontWeight: FontWeight.bold
        ,fontSize: 15),
      ),
    ),
      ),
    );
  }
}
