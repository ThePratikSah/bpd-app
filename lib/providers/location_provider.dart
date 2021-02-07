import 'package:flutter/material.dart';
import 'dart:async';

import 'package:location/location.dart';

class LocationProvider with ChangeNotifier {
  double _userCurrentLatitude = 0.0;
  double _userCurrentLongitude = 0.0;

  double get userCurrentLatitude {
    return _userCurrentLatitude;
  }

  double get userCurrentLongitude {
    return _userCurrentLongitude;
  }

  //function to fetch and set user current location
  Future<void> getAndSetCurrentUserLocation() async {
    final locationData = await Location().getLocation();
    _userCurrentLatitude = locationData.latitude;
    _userCurrentLongitude = locationData.longitude;
    notifyListeners();
  }
}
