import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_events/app/landing_page.dart';
import 'package:my_events/services/auth.dart';
import 'package:my_events/services/customisation.dart';

void main() {
  runApp(MyApp());
}
Future <ThemeData> getUserTheme() async{
  return await Customisation.getTheme();
}
class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return FutureBuilder(
      future: getUserTheme(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(
                child:CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2.0,
                )
              );
          case ConnectionState.waiting:
            return Center(
                child:CircularProgressIndicator(
                  backgroundColor: Colors.white,
                  strokeWidth: 2.0,
                )
              );
          default:
            if (snapshot.hasError)
              return CircularProgressIndicator();
            else {
              return MaterialApp(
                color: Colors.black,
                debugShowCheckedModeBanner: false,
                title: 'MyEvents',
                theme: snapshot.data,
                home: LandingPage(auth:Auth())
              );
            }
        }
      },
    );
  }
}