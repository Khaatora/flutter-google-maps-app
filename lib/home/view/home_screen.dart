import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_app/home/view_model/home_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => HomeProvider(), child: const HomeView());
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final Completer<GoogleMapController> _googleMapCompleter;
  late final Future<void> locationGetter;
  GoogleMapController? _googleMapController;

  @override
  void initState() {
    super.initState();
    locationGetter = context.read<HomeProvider>().getCurrentLocation();
    _googleMapCompleter = Completer<GoogleMapController>();
    context.read<HomeProvider>().updateUserLocationFunction = _updateUserLocation;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GPS"),
      ),
      body: FutureBuilder(
        future: locationGetter,
        builder: (locationContext, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator.adaptive(),
              );
            case ConnectionState.done:
              final homeProvider = locationContext.watch<HomeProvider>();
              return GoogleMap(
                initialCameraPosition: HomeProvider.myLocation,
                mapType: MapType.normal,
                onTap: (latLng) {
                  final homeProvider =locationContext.read<HomeProvider>();
                  Marker marker = Marker(markerId: MarkerId("Short Press Marker no.${homeProvider.getAndIncrementCounter()}"), position: latLng);
                  homeProvider.markers.add(marker);
                },
                onLongPress: (latLng) {
                  Marker marker = Marker(markerId: const MarkerId("Long Press Marker"), position: latLng);
                  locationContext.read<HomeProvider>().markers.add(marker);
                },
                markers: homeProvider.markers,
                onMapCreated: (controller) {
                  _googleMapCompleter.complete(controller);
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _gotToTheLake,
        label: const Text("To The Lake!"),
        icon: const Icon(Icons.directions_boat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _gotToTheLake() async {
    if(_googleMapController!=null){
      _googleMapController!.dispose();
    }
    _googleMapController = await _googleMapCompleter.future;
    _googleMapController
        !.animateCamera(CameraUpdate.newCameraPosition(HomeProvider.kLake));
  }
  Future<void> _updateUserLocation() async{
    if(_googleMapController!=null){
      _googleMapController!.dispose();
    }
    _googleMapController = await _googleMapCompleter.future;
    _googleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(HomeProvider.myLocation));
  }

  @override
  void dispose() {
    final homeProvider = context.read<HomeProvider>();
    if(_googleMapController!=null) _googleMapController!.dispose();
    if(homeProvider.locationStreamSubscription!=null) homeProvider.locationStreamSubscription!.cancel();
    super.dispose();
  }
}
