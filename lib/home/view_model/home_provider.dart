import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeProvider extends ChangeNotifier{
  late PermissionStatus permissionStatus;
  late LocationData locationData;
  Location location = Location();
  bool serviceEnabled = false;
  int markerCounter = 0;
  StreamSubscription<LocationData>? locationStreamSubscription;

  int getAndIncrementCounter(){

    return ++markerCounter;
  }

  late Marker userMarker;
  Set<Marker> markers = {};

  late Future<void> Function() updateUserLocationFunction;

  static late CameraPosition myLocation;

  //google maps example variables
  static const CameraPosition kLake = CameraPosition(
      bearing: 190.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 89.440717697143555,);

  Future<bool> isServiceEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if(serviceEnabled == false){
      serviceEnabled = await location.requestService();
    }
    return serviceEnabled;
  }

  Future<bool> isPermissionGranted() async{
    permissionStatus = await location.hasPermission();
    if(permissionStatus == PermissionStatus.denied){
      permissionStatus = await location.requestPermission();
    }
    return permissionStatus == PermissionStatus.granted;
  }

  Future<void> getCurrentLocation() async {
    var permission = await isPermissionGranted();
    if(!permission) return;
    var service = await isServiceEnabled();
    if(!service) return;
    location.changeSettings(
      accuracy: LocationAccuracy.balanced,
    );
    locationStreamSubscription = location.onLocationChanged.listen((event) async{
      locationData = event;
      myLocation = CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!),
          zoom: 14.4746,
          tilt: 45.0
      );
      log("My Location :\nlat:${locationData.latitude}, long:${locationData.longitude}");
      await updateUserLocationFunction();
      userMarker = Marker(markerId: const MarkerId("User Location"), position: LatLng(locationData.latitude!, locationData.longitude!) );
      markers.add(userMarker);
      notifyListeners();
    });

  }
}