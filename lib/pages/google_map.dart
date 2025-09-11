import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapFlutter extends StatefulWidget {
  const GoogleMapFlutter({super.key});

  @override
  State<GoogleMapFlutter> createState() => _GoogleMapFlutterState();
}

late GoogleMapController googleMapController;

class _GoogleMapFlutterState extends State<GoogleMapFlutter> {
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  final List<LatLng> points = [
    LatLng(11.556374, 104.928210),
    LatLng(11.576129, 104.923085),
    LatLng(11.563894, 104.931235),
  ];
  Set<Marker> markers = {};
  final List<String> icons = [
    'assets/images/current_location.png',
    'assets/images/destination_location.png',
    'assets/images/source_location.png',
  ];

  final List<String> locationNames = [
    'Kandal',
    'Kampot',
    'Kaeb',
    'Preah Sihanouk',
  ];
  final List<LatLng> coordinates = [
    LatLng(11.481416, 104.944830), // Kandal
    LatLng(10.732535, 104.379191), // Kampot
    LatLng(10.536089, 104.355916), // Kaeb
    LatLng(10.626891, 103.511532), // Preah Sihanouk
  ];

  Map<PolylineId, Polyline> polylinePoint = {};

  @override
  void initState() {
    getPolyLinePoint().then(
      (locationsPoints) => {
        print(locationsPoints),
        _createPolyline(locationsPoints),
      },
    );
    _customIcon();
    displayMarker();
    super.initState();
  }

  void _customIcon() {
    for (int i = 0; i < points.length; i++) {
      BitmapDescriptor.asset(ImageConfiguration(), icons[i]).then(
        (icon) => setState(() {
          customIcon = icon;
          markers
            ..removeWhere((m) => m.position == points[i])
            ..add(
              Marker(
                markerId: MarkerId(i.toString()),
                position: points[i],
                draggable: true,
                icon: customIcon,
                onDragEnd: (value) {
                  print(value);
                  googleMapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(value.latitude, value.longitude),
                        zoom: 14,
                      ),
                    ),
                  );
                },
              ),
            );
        }),
      );
    }
  }

  void displayMarker() {
    for (int i = 0; i < points.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('Location: ${i.toString()}'),
          position: points[i],
          icon: customIcon,
          draggable: true,
          onDragEnd: (LatLng position) async {
            print(
              'Location was moved to this: ${position.latitude}, ${position.longitude}',
            );
            // Move camera to new position of marker
            googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 16,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Map',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(11.556374, 104.928210),
              zoom: 14,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              googleMapController = controller;
            },
            polylines: Set<Polyline>.of(polylinePoint.values),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(color: Colors.transparent),
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    print(index);
                    setState(() {
                      // add marker on tap
                      markers.add(
                        Marker(
                          markerId: MarkerId('index: ${index.toString()}'),
                          position: coordinates[index],
                          draggable: true,
                          onDragEnd: (value) {
                            googleMapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(
                                    value.latitude,
                                    value.longitude,
                                  ),
                                  zoom: 14,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 5),
                    width: double.infinity,
                    height: 50,

                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(150),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            locationNames[index],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool isServiceEnabled;
          LocationPermission permission;

          // Check if location service is enabled
          isServiceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!isServiceEnabled) 'Location service is disable.';

          // Check and request permission
          permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.deniedForever) {
              return Future.error('Location Permission is denied.');
            }
          }

          // Get current position
          Position position = await Geolocator.getCurrentPosition();

          // Move camera to current location
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14,
              ),
            ),
          );
        },
        child: Icon(Icons.my_location),
      ),
    );
  }

  Future<List<LatLng>> getPolyLinePoint() async {
    List<LatLng> coordinates = [];
    PolylinePoints polylinePoints = PolylinePoints(
      apiKey: "AIzaSyDefMWW9rHDztsRu8SGvrxwszlXen9jI7E",
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(11.563894, 104.931235),
        destination: PointLatLng(11.576129, 104.923085),
        mode: TravelMode.driving,
      ),
    );

    // Convert polyline points into LatLng list
    for (final p in result.points) {
      coordinates.add(LatLng(p.latitude, p.longitude));
    }

    return coordinates;
  }

  void _createPolyline(List<LatLng> position) {
    PolylineId id = PolylineId('WP');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: position,
      width: 8,
    );

    setState(() {
      polylinePoint[id] = polyline;
    });
  }
}
