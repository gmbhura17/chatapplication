import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {


  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Example Page"),
      ),
      body: Center(child: Text("hello",style: TextStyle(fontSize: 50),)),
    );
  }
}
