import './screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

ThemeData theme =  new ThemeData(
  primaryColor: Colors.black,
  backgroundColor: Colors.white10,
  fontFamily: 'PTSans',
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Photo View',
      theme: theme,
      home: new Scaffold(
        body: new HomeScreen(),
      ),
    );
  }
}
