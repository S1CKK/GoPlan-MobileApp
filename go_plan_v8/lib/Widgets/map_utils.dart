import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapUtils{
  MapUtils._();

  static Future<void> openMap(double? latitute, double? longtitute,) async{
    String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$latitute,$longtitute";

    if(await canLaunchUrlString(googleMapUrl)){
      await launchUrlString(googleMapUrl);
      print("launch");
    }else{
      throw 'Could not open the Map';
    }
  }
}