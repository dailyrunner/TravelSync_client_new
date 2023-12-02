import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:travelsync_client_new/widget/globals.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GuideLocationView extends StatefulWidget {
  const GuideLocationView({Key? key}) : super(key: key);

  @override
  State<GuideLocationView> createState() => GuideLocationViewState();
}

class GuideLocationViewState extends State<GuideLocationView> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.4222, -122.086);
  static const LatLng destination = LatLng(37.411, -122.072);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then(
      (location) {
        currentLocation = location;
      },
    );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;

        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              )),
        ));
        setState(() {});
      },
    );
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_source.png")
        .then((icon) => sourceIcon = icon);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Pin_destination.png")
        .then((icon) => destinationIcon = icon);
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/Badge.png")
        .then((icon) => currentLocationIcon = icon);
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: currentLocation == null
          ? const Center(child: Text("Loading"))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation!.latitude!,
                  currentLocation!.longitude!,
                ),
                zoom: 13.5,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylineCoordinates,
                  color: primaryColor,
                  width: 6,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  icon: currentLocationIcon,
                  position: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!.longitude!,
                  ),
                ),
                Marker(
                  markerId: const MarkerId("source"),
                  icon: sourceIcon,
                  position: sourceLocation,
                ),
                Marker(
                  markerId: const MarkerId("destination"),
                  icon: destinationIcon,
                  position: destination,
                ),
              },
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            ),
    );
  }
}
