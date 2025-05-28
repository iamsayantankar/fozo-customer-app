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
import '../../utils/http/api.dart';
import '../../widgets/custom_button_widget.dart';

class AddNewDeliveryLocationScreen extends StatefulWidget {
  const AddNewDeliveryLocationScreen({
    super.key,
  });
  @override
  State<AddNewDeliveryLocationScreen> createState() =>
      _AddNewDeliveryLocationScreenState();
}

class _AddNewDeliveryLocationScreenState
    extends State<AddNewDeliveryLocationScreen> {
  List searchList = [];

  final Completer<GoogleMapController> _controller = Completer();

// Initial Location
  final LatLng _initialLatLng = LatLng(22.420524, 87.337126);

// Location & Address states
  LatLng? selectLocation;
  String? selectPlaceAddress;
  Placemark? place;

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

    setState(() {
      place = placemarks.first;

      selectPlaceAddress =
          "${place?.street}, ${place?.locality}, ${place?.postalCode}";
    });

    _getDetailsMapDataEntry();
  }

  /// When user selects a place from search
  Future<void> onPlaceSelected(Map placeData) async {
    // Get location from Google Place result
    double lat = placeData["geometry"]["location"]["lat"];
    double lng = placeData["geometry"]["location"]["lng"];
    String address = placeData["formatted_address"];

    LatLng newPosition = LatLng(lat, lng);

    selectLocation = newPosition;
    selectPlaceAddress = address;
    _marker = Marker(
      markerId: MarkerId("selected_place"),
      position: newPosition,
      infoWindow: InfoWindow(title: "Selected Place"),
    );

    // Move camera
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newPosition));

    // Get human-readable address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      lat,
      lng,
    );

    place = placemarks.first;
    setState(() {});
    _getDetailsMapDataEntry();
  }

  // Todo: Map Address
  bool isDefault = true;
  final _formKey = GlobalKey<FormState>();

  Map<String, TextEditingController> _controllers = {
    "Recipient Name": TextEditingController(text: ""),
    "Street Address": TextEditingController(text: ""),
    "Apartment": TextEditingController(text: ""),
    "City": TextEditingController(text: ""),
    "State": TextEditingController(text: ""),
    "Postal Code": TextEditingController(text: ""),
    "Country": TextEditingController(text: ""),
    "Phone Number": TextEditingController(text: ""),
    "Delivery Instructions": TextEditingController(text: "")
  };

  Future<void> _getDetailsMapDataEntry() async {
    setState(() {
      _controllers = {
        "Recipient Name": TextEditingController(text: ""),
        "Street Address": TextEditingController(text: place?.street),
        "Apartment": TextEditingController(text: place?.name),
        "City": TextEditingController(text: place?.locality),
        "State": TextEditingController(text: place?.administrativeArea),
        "Postal Code": TextEditingController(text: place?.postalCode),
        "Country": TextEditingController(text: place?.country),
        "Phone Number": TextEditingController(text: ""),
        "Delivery Instructions": TextEditingController(text: "")
      };
    });
  }

  @override
  Widget build(BuildContext context) {
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
          "Add delivery location",
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
                    /// Confirm Button
                    CustomButton(
                        text: "Confirm",
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16.r)),
                            ),
                            builder: (BuildContext context) {
                              String selectedType = 'Home';

                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setModalState) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.75,
                                    child: Padding(
                                      padding: EdgeInsets.all(16.r),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 4.h,
                                                width: 50.w,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 16.h),
                                            Text(
                                              "Save address as",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1D1D1B),
                                              ),
                                            ),
                                            SizedBox(height: 10.h),
                                            Row(
                                              children: [
                                                // Home Chip
                                                ChoiceChip(
                                                  label: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.home_outlined,
                                                          size: 18.sp,
                                                          color: selectedType ==
                                                                  'Home'
                                                              ? Color(
                                                                  0xFF073228)
                                                              : Color(
                                                                  0xFF5A6474)),
                                                      SizedBox(width: 6.w),
                                                      Text(
                                                        "Home",
                                                        style: TextStyle(
                                                          color: selectedType ==
                                                                  'Home'
                                                              ? Color(
                                                                  0xFF073228)
                                                              : Color(
                                                                  0xFF5A6474),
                                                          fontSize: 13.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  selected:
                                                      selectedType == 'Home',
                                                  onSelected: (_) {
                                                    setModalState(() =>
                                                        selectedType = 'Home');
                                                  },
                                                  selectedColor:
                                                      Color(0xFFEAF8C4),
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color:
                                                            Color(0xFFE0E3E7)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.r),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 8.h),
                                                ),
                                                SizedBox(width: 8.w),

                                                // Work Chip
                                                ChoiceChip(
                                                  label: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.work_outline,
                                                          size: 18.sp,
                                                          color: selectedType ==
                                                                  'Work'
                                                              ? Color(
                                                                  0xFF073228)
                                                              : Color(
                                                                  0xFF5A6474)),
                                                      SizedBox(width: 6.w),
                                                      Text(
                                                        "Work",
                                                        style: TextStyle(
                                                          color: selectedType ==
                                                                  'Work'
                                                              ? Color(
                                                                  0xFF073228)
                                                              : Color(
                                                                  0xFF5A6474),
                                                          fontSize: 13.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  selected:
                                                      selectedType == 'Work',
                                                  onSelected: (_) {
                                                    setModalState(() =>
                                                        selectedType = 'Work');
                                                  },
                                                  selectedColor:
                                                      Color(0xFFEAF8C4),
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color:
                                                            Color(0xFFE0E3E7)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.r),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 8.h),
                                                ),
                                                SizedBox(width: 8.w),

                                                // Other Chip
                                                ChoiceChip(
                                                  label: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 18.sp,
                                                          color: selectedType ==
                                                                  'Other'
                                                              ? Color(
                                                                  0xFF073228)
                                                              : Color(
                                                                  0xFF5A6474)),
                                                      SizedBox(width: 6.w),
                                                      Text(
                                                        "Other",
                                                        style: TextStyle(
                                                          color: selectedType ==
                                                                  'Other'
                                                              ? Color(
                                                                  0xFF073228)
                                                              : Color(
                                                                  0xFF5A6474),
                                                          fontSize: 13.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  selected:
                                                      selectedType == 'Other',
                                                  onSelected: (_) {
                                                    setModalState(() =>
                                                        selectedType = 'Other');
                                                  },
                                                  selectedColor:
                                                      Color(0xFFEAF8C4),
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color:
                                                            Color(0xFFE0E3E7)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.r),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12.w,
                                                      vertical: 8.h),
                                                ),
                                              ],
                                            ),
                                            Form(
                                              key: _formKey,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ..._controllers.keys
                                                      .map((field) => Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        16.h),
                                                            child:
                                                                _buildProfileField(
                                                              label: field,
                                                              controller:
                                                                  _controllers[
                                                                      field]!,
                                                            ),
                                                          )),
                                                  Row(
                                                    children: [
                                                      Checkbox(
                                                        value: isDefault,
                                                        onChanged: (value) =>
                                                            setState(() =>
                                                                isDefault =
                                                                    value!),
                                                      ),
                                                      Text("Set as Default"),
                                                    ],
                                                  ),
                                                  SizedBox(height: 30.h),
                                                  CustomButton(
                                                    text: "Add New Address",
                                                    onPressed: () async {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        Map<String, dynamic>
                                                            formData = {
                                                          "name": selectedType,
                                                          "recipientName":
                                                              _controllers[
                                                                          "Recipient Name"]
                                                                      ?.text ??
                                                                  '',
                                                          "streetAddress":
                                                              _controllers[
                                                                          "Street Address"]
                                                                      ?.text ??
                                                                  '',
                                                          "apartment": _controllers[
                                                                      "Apartment"]
                                                                  ?.text ??
                                                              '',
                                                          "city": _controllers[
                                                                      "City"]
                                                                  ?.text ??
                                                              '',
                                                          "state": _controllers[
                                                                      "State"]
                                                                  ?.text ??
                                                              '',
                                                          "postalCode":
                                                              _controllers[
                                                                          "Postal Code"]
                                                                      ?.text ??
                                                                  '',
                                                          "country": _controllers[
                                                                      "Country"]
                                                                  ?.text ??
                                                              '',
                                                          "phoneNumber":
                                                              _controllers[
                                                                          "Phone Number"]
                                                                      ?.text ??
                                                                  '',
                                                          "deliveryInstructions":
                                                              _controllers[
                                                                          "Delivery Instructions"]
                                                                      ?.text ??
                                                                  '',
                                                          "isDefault":
                                                              isDefault, // if controlled via checkbox/switch, keep as is
                                                        };

                                                        await ApiService
                                                            .postRequest(
                                                                "address",
                                                                formData);

                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }),

                    SizedBox(height: 8.h),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  style: TextStyle(fontSize: 14.sp),
                  decoration: const InputDecoration.collapsed(hintText: ""),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // void _showAddressPopup(BuildContext context) async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => UpdateDeliveryLocationDataScreen(
  //         // selectLocation: selectLocation,
  //         selectPlaceAddress: selectPlaceAddress,
  //         place: place,
  //       ),
  //     ),
  //   );
  //
  //   // // Wait for popup to close
  //   // await showDialog(
  //   //   context: context,
  //   //   builder: (context) {
  //   //     return Dialog(
  //   //       child: SingleChildScrollView(
  //   //         child: AddressForm(
  //   //           selectLocation: selectLocation,
  //   //           selectPlaceAddress: selectPlaceAddress,
  //   //           place: place,
  //   //         ),
  //   //       ),
  //   //     );
  //   //   },
  //   // );
  //
  //   // After popup closes, navigate to a new screen
  //   // Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute(
  //   //     builder: (context) =>
  //   //         SelectLocationScreen(), // Replace with your actual screen
  //   //   ),
  //   // );
  //
  //   Navigator.pop(context);
  // }
}

// class AddressForm extends StatefulWidget {
//   final LatLng? selectLocation;
//   final String? selectPlaceAddress;
//   final Placemark? place;
//
//   const AddressForm({
//     super.key,
//     required this.selectLocation,
//     required this.selectPlaceAddress,
//     required this.place,
//   });
//
//   @override
//   _AddressFormState createState() => _AddressFormState();
// }
//
// class _AddressFormState extends State<AddressForm> {
//   final _formKey = GlobalKey<FormState>();
//
//   String name = "";
//   String recipientName = "";
//   String? streetAddress = "";
//   String? apartment = "";
//   String? city = "";
//   String? state = "";
//   String? postalCode = "";
//   String? country = "";
//   String phoneNumber = "";
//   String deliveryInstructions = "";
//   bool isDefault = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _getData();
//   }
//
//   void _getData() {
//     streetAddress = widget.place?.street;
//     city = widget.place?.locality;
//     postalCode = widget.place?.postalCode;
//     country = widget.place?.country;
//     state = widget.place?.administrativeArea;
//     apartment = widget.place?.name;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 350,
//       padding: EdgeInsets.all(16),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Enter Address',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 16),
//             _buildTextField('Label', name, (val) => name = val),
//             _buildTextField(
//                 'Recipient Name', recipientName, (val) => recipientName = val),
//             _buildTextField(
//                 'Street Address', streetAddress!, (val) => streetAddress = val),
//             _buildTextField('Apartment', apartment!, (val) => apartment = val),
//             _buildTextField('City', city!, (val) => city = val),
//             _buildTextField('State', state!, (val) => state = val),
//             _buildTextField(
//                 'Postal Code', postalCode!, (val) => postalCode = val),
//             _buildTextField('Country', country!, (val) => country = val),
//             _buildTextField(
//                 'Phone Number', phoneNumber, (val) => phoneNumber = val),
//             _buildTextField('Delivery Instructions', deliveryInstructions,
//                 (val) => deliveryInstructions = val),
//             Row(
//               children: [
//                 Checkbox(
//                   value: isDefault,
//                   onChanged: (value) => setState(() => isDefault = value!),
//                 ),
//                 Text("Set as Default"),
//               ],
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_formKey.currentState!.validate()) {
//                   Map<String, dynamic> formData = {
//                     "name": name,
//                     "recipientName": recipientName,
//                     "streetAddress": streetAddress,
//                     "apartment": apartment,
//                     "city": city,
//                     "state": state,
//                     "postalCode": postalCode,
//                     "country": country,
//                     "phoneNumber": phoneNumber,
//                     "isDefault": isDefault,
//                     "deliveryInstructions": deliveryInstructions,
//                   };
//
//                   final resOutlate =
//                       await ApiService.postRequest("address", formData);
//
//                   Navigator.pop(context);
//                 }
//               },
//               child: Text('Submit..'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(
//       String label, String initialValue, Function(String) onChanged) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: TextFormField(
//         initialValue: initialValue,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//         ),
//         onChanged: onChanged,
//         validator: (value) =>
//             value == null || value.isEmpty ? 'Required' : null,
//       ),
//     );
//   }
// }
