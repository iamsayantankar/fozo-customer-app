import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:fozo_customer_app/core/constants/colour_constants.dart';
// import 'package:fozo_customer_app/provider/address_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/colour_constants.dart';
import '../../widgets/custom_button_widget.dart';

class UpdateLocationForHome extends StatefulWidget {
  const UpdateLocationForHome({
    super.key,
  });

  @override
  State<UpdateLocationForHome> createState() => _UpdateLocationForHomeState();
}

class _UpdateLocationForHomeState extends State<UpdateLocationForHome> {
  List searchList = [];

  final Completer<GoogleMapController> _controller = Completer();

// Initial Location
  final LatLng _initialLatLng = LatLng(22.420524, 87.337126);

// Location & Address states
  LatLng? selectLocation;
  String? selectPlaceAddress;

  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _setInitialMarker();
    _getCurrentLocation();
  }

  void _setInitialMarker() {
    selectLocation = _initialLatLng;
    _marker = Marker(
      markerId: MarkerId('current_location'),
      position: _initialLatLng,
      infoWindow: InfoWindow(title: "Initial Location"),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng newPosition = LatLng(position.latitude, position.longitude);

    // Update marker and selected location
    setState(() {
      selectLocation = newPosition;
      _marker = Marker(
        markerId: MarkerId('current_location'),
        position: newPosition,
        infoWindow: InfoWindow(title: "Your Location"),
      );
    });

    // Move camera to new location
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newPosition));

    // Get human-readable address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks.first;
    setState(() {
      selectPlaceAddress =
          "${place.street}, ${place.locality}, ${place.postalCode}";
    });
  }

  /// When user selects a place from search
  Future<void> onPlaceSelected(Map placeData) async {
    // Get location from Google Place result
    double lat = placeData["geometry"]["location"]["lat"];
    double lng = placeData["geometry"]["location"]["lng"];
    String address = placeData["formatted_address"];

    LatLng newPosition = LatLng(lat, lng);

    // Update everything
    setState(() {
      selectLocation = newPosition;
      selectPlaceAddress = address;
      _marker = Marker(
        markerId: MarkerId("selected_place"),
        position: newPosition,
        infoWindow: InfoWindow(title: "Selected Place"),
      );
    });

    // Move camera
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<AddressFormProvider>(context);
    // Future.microtask(() => provider.init());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColor.backgroundColor,
        title: Text(
          "Add location",
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          /// Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialLatLng,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _marker != null ? {_marker!} : {},
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          /// Search Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5.r,
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) async {
                if (value != "") {
                  // Do something with the value

                  String encodedUrl = Uri.encodeFull(value.toString().trim());

                  final response = await http.get(Uri.parse(
                      'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodedUrl}&key=AIzaSyAy8IOF5Fdx7gPUfWWelE_-kYFiyzYZqYE'));

                  if (response.statusCode >= 200 && response.statusCode < 300) {
                    Map data = jsonDecode(response.body);
                    searchList = data["results"];
                    setState(() {});
                  } else {
                    print(
                        'HTTP Error: ${response.statusCode} - ${response.body}');
                    Map data = {};
                  }
                }
              },
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: "Search for area, street name...",
                hintStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
              ),
            ),
          ),

          /// Bottom Location Confirmation
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.r,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Scrollable String List (min 3 items height)

                    searchList.isNotEmpty
                        ? SizedBox(
                            height: 100.h,
                            child: ListView.builder(
                              itemCount: searchList.length,
                              itemBuilder: (context, index) {
                                Map onePlace = searchList[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4.h, horizontal: 8.w),
                                  child: GestureDetector(
                                    onTap: () {
                                      onPlaceSelected(
                                          onePlace); // Pass the whole place object
                                      // Your logic here
                                    },
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(12.r),
                                        child: Text(
                                          "${onePlace["name"]} - ${onePlace["formatted_address"]}",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : SizedBox.shrink(),

                    // SizedBox(height: 12.h),

                    /// Selected Location Display
                    Container(
                      margin: EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(12),
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        // color: Color(0xFFFCFFF2),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFEFF1E2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.green.shade900,
                            size: 24.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectPlaceAddress ?? "",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8.h),

                    /// Confirm Button
                    CustomButton(
                      text: "Confirm",
                      onPressed: () async {
                        Navigator.pop(context,
                            selectPlaceAddress); // Can be any data type
                      },
                    ),
                    SizedBox(height: 8.h),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
