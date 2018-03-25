import 'package:flutter/material.dart';
import 'dart:core';
import 'package:mini_red/mini_red.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'A mobile Reddit reader',
      theme: new ThemeData(
        primaryColor: Colors.red,
      ),
      home: new RedditPosts(),
    );
  }
}