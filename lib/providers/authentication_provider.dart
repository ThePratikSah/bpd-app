import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider with ChangeNotifier {
  String _token;
  String _phone;
  String _userId;
  Timer _authTimer;
  DateTime _expiryDate;

  final String baseUrl;

//constructor
  AuthenticationProvider(
    this.baseUrl,
  );

  //getter functions
  bool get isAuthenticated {
    return token != null; //check from token getter method if token is not null
  }

  String get userId {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null &&
        _userId != null) {
      return _userId;
    }
    return null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get phone {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _phone;
    }
    return null;
  }

  //signup using phone
  Future<void> signupOrGetOtpUsingPhone({String phone}) async {
    try {
      final response = await http.post(
        baseUrl + '/auth/user-auth',
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'phone': phone,
        }),
      );
      final statusCode = response.statusCode;
      final responseData = jsonDecode(response.body);
      if (statusCode == 200 || statusCode == 201) {
        // print(responseData);
        print(statusCode);
      } else if (statusCode == 401) {
        // print('Not Authorized');
        // print(responseData);
        // throw HttpException(responseData['message']);
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

//login using phone and otp
  Future<void> loginUsingPhoneAndOtp({String phone, String otp}) async {
    try {
      final response = await http.post(
        baseUrl + '/auth/user/login/phone',
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{'phone': phone, 'otp': otp}),
      );
      final statusCode = response.statusCode;
      final responseData = jsonDecode(response.body);
      if (statusCode == 200) {
        print(responseData);
        print(statusCode);
      } else if (statusCode == 500) {
        print('Not Authorized');
        // print(responseData);
        // throw HttpException(responseData['message']);
      }
      _token = responseData['token'];
      _userId = responseData['userId'];
      _phone = phone;
      _expiryDate = DateTime.now().add(
        Duration(
          hours: 23,
          minutes: 55,
        ),
      );
      print(_token);
      _autoLogout();
      notifyListeners();
      //store login data
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'phone': _phone,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      print(error);
      throw error;
    }
  }

//logout function
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    _phone = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inMinutes;
    _authTimer = Timer(Duration(minutes: timeToExpiry), logout);
  }

  //autologin method
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _phone = extractedUserData['phone'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }
}
