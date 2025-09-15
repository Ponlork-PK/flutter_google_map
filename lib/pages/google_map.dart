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

  final TextEditingController sourceController = TextEditingController();
  final TextEditingController directionController = TextEditingController();

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
    // getPolyLinePoint().then(
    //   (locationsPoints) => {
    //     print(locationsPoints),
    //     _createPolyline(locationsPoints),
    //   },
    // );
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
                            // googleMapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(value.latitude, value.longitude), zoom: 14)));
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

          Positioned(
            right: 14,
            bottom: 105,
            child: SizedBox(
              width: 56,
              height: 56,
              child: IconButton(
                style: IconButton.styleFrom(
                  iconSize: 26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.white,
                ),
                icon: Icon(Icons.directions),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Set Directions'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 10,
                          children: [
                            TextFormField(
                              controller: sourceController,
                              decoration: InputDecoration(
                                label: Text('Source'),
                                hint: Text('ex. 11.556374,104.928210'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: directionController,
                              decoration: InputDecoration(
                                label: Text('Destination'),
                                hint: Text('ex. 11.572272,104.925588'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),

                          ],
                        ),
                        actions: [
                          
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                            }, 
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async{

                              final sourceText = sourceController.text.trim();
                              final destinationText = directionController.text.trim();
                              
                              final srcPart = sourceText.split(',');
                              final dstPart = destinationText.split(',');

                              final srcLat = double.parse(srcPart[0]);
                              final srcLong = double.parse(srcPart[1]);
                              final dstLat = double.parse(dstPart[0]);
                              final dstLong = double.parse(dstPart[1]);

                              final LatLng source = LatLng(srcLat, srcLong);
                              final LatLng destination = LatLng(dstLat, dstLong);

                              print("Source: $source");
                              print("Destination: $destination");

                              setState(() {
                                markers.removeWhere((marker)=> marker.markerId.value == 'source' || marker.markerId.value == 'destination');
                                markers.add(
                                  Marker(
                                    markerId: MarkerId('source'),
                                    position: source,
                                    draggable: true,
                                  ),
                                );
                                markers.add(
                                  Marker(
                                    markerId: MarkerId('destination'),
                                    position: destination,
                                    draggable: true,
                                  ),
                                );
                              });

                              // Fit camera to show both pins nicely
                              final southWest = LatLng(
                                srcLat < dstLat ? srcLat : dstLat,
                                srcLong < dstLong ? srcLong : dstLong,
                              );
                              final northEast = LatLng(
                                srcLat > dstLat ? srcLat : dstLat,
                                srcLong > dstLong ? srcLong : dstLong,
                              );
                              final bounds = LatLngBounds(southwest: southWest, northeast: northEast);

                              // Add some padding around bounds
                              await googleMapController
                                  .animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));

                              final PointLatLng origin = PointLatLng(srcLat, srcLong);
                              final PointLatLng goal = PointLatLng(dstLat, dstLong);
                              getPolyLinePoint(origin, goal).then((value) => {_createPolyline(value)});
                              

                              Navigator.pop(context);

                            },
                            child: Text('Done'),
                          ),
                        ],
                      );
                    },
                  );
                },
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

  Future<List<LatLng>> getPolyLinePoint(PointLatLng source, PointLatLng destination) async {
    List<LatLng> coordinates = [];
    PolylinePoints polylinePoints = PolylinePoints(
      apiKey: "THE_API_KEY",
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: source,
        destination: destination,
        // origin: PointLatLng(11.563894, 104.931235),
        // destination: PointLatLng(11.576129, 104.923085),
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

