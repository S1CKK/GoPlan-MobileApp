
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlobalMethod {
  static void showErrorDialog(
      {required String error, required BuildContext ctx}) {
    showDialog(
        context: ctx,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.error,
                    color: Colors.grey,
                    size: 35,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'เกิดข้อผิดพลาดบางอย่าง',style: TextStyle(fontFamily: 'Kanit',fontSize: 19),
                  ),
                ),
              ],
            ),
            content: Text(
              error,
              style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Kanit'),
            ),
            actions: [
              TextButton(onPressed: (){
                 Navigator.canPop(context)?Navigator.pop(context) : null;
              },
               child: const Text(
                "OK",style: TextStyle(color: Colors.red,fontFamily: 'Kanit'),
               ),)
            ],
          );
        });
  }
}
