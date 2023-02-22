
import 'package:chatapplication/Chatapp.dart';
import 'package:chatapplication/ViewPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  checkdata() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("Name"))
    {
      Navigator.of(context).pop();
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context)=>ViewPage())
      );
    }
    else
    {
      Navigator.of(context).pop();
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context)=>Chatapp())
      );
    }
  }
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000),(){
      checkdata();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset("img/logo.webp",width: 200),
    );
  }
}

