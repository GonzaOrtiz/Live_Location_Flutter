import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_location/constants.dart';
import 'package:location/location.dart';

class OrderTrakingPage extends StatefulWidget {
  const OrderTrakingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrakingPage> createState() => _OrderTrakingPageState();
}

class _OrderTrakingPageState extends State<OrderTrakingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng _originLocation = LatLng(-31.420090, -62.091278);
  static const LatLng _destLocation = LatLng(-31.438770, -62.116617);
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor originIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinoIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLocation) {
      currentLocation = newLocation;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target:
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 13.5,
        ),
      ));

      setState(() {});
    });
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(_originLocation.latitude, _originLocation.longitude),
        PointLatLng(_destLocation.latitude, _destLocation.longitude),
        travelMode: TravelMode.bicycling);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    setState(() {});
  }

  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Location"),
      ),
      body: currentLocation == null
          ? const Center(child: Text('Cargando'))
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                  zoom: 13.5),
              polylines: {
                Polyline(
                    polylineId: PolylineId('Ruta'),
                    points: polylineCoordinates,
                    width: 6)
              },
              markers: {
                Marker(
                    markerId: MarkerId('Ubicación actual'),
                    icon: originIcon,
                    position: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!)),
                Marker(
                    markerId: MarkerId('Origen'),
                    icon: originIcon,
                    position: _originLocation),
                Marker(
                    markerId: MarkerId('Destino'),
                    icon: destinoIcon,
                    position: _destLocation),
              },
              onMapCreated: (mapController) {
                _controller.complete(mapController);
              },
            ),
    );
  }
}
