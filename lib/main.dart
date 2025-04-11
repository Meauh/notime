import 'package:flutter/material.dart';

void main (){
  runApp(NotimeApp());
}

class NotimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return (
      MaterialApp(
        title: 'No Time',
        home: MainUI(),
      )
    );
    throw UnimplementedError();
  }
}

class MainUI extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    // TODO: implement build
    return (Scaffold(
      appBar: AppBar(title: Text('No time', style: TextStyle(color: Colors.white, fontSize: 32),),  backgroundColor: Colors.transparent),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text('30', style: TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.w900),),),
          Center(child: Text('.00', style: TextStyle(color: Colors.white70, fontSize: 56, fontWeight: FontWeight.w900,),),),
        ],
      ),
      backgroundColor: Colors.lightGreen,
    )
      );
  }
}