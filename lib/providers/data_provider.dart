import 'package:flutter/material.dart';

class DataProvider with ChangeNotifier {
  final String baseUrl;

  //constructor
  DataProvider(this.baseUrl);
}
