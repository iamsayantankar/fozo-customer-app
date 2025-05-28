// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geocoding/geocoding.dart';
//
// import '../../core/constants/colour_constants.dart';
// import '../../utils/helper/shared_preferences_helper.dart';
// import '../../utils/http/api.dart';
// import '../home/home_screen.dart';
//
// class DeliveryLocationDataScreen extends StatefulWidget {
//   // final LatLng? selectLocation;
//   final String idToken;
//   final String fullName;
//   final String contactNumber;
//   final String address;
//   final String? selectPlaceAddress;
//   final Placemark? place;
//
//   const DeliveryLocationDataScreen({
//     super.key,
//     // required this.selectLocation,
//     required this.idToken,
//     required this.fullName,
//     required this.contactNumber,
//     required this.address,
//     required this.selectPlaceAddress,
//     required this.place,
//   });
//
//   @override
//   State<DeliveryLocationDataScreen> createState() =>
//       _DeliveryLocationDataScreenState();
// }
//
// class _DeliveryLocationDataScreenState
//     extends State<DeliveryLocationDataScreen> {
//   bool isDefault = true;
//   final _formKey = GlobalKey<FormState>();
//
//   Map<String, TextEditingController> _controllers = {
//     "Label": TextEditingController(text: ""),
//     "Recipient Name": TextEditingController(text: ""),
//     "Street Address": TextEditingController(text: ""),
//     "Apartment": TextEditingController(text: ""),
//     "City": TextEditingController(text: ""),
//     "State": TextEditingController(text: ""),
//     "Postal Code": TextEditingController(text: ""),
//     "Country": TextEditingController(text: ""),
//     "Phone Number": TextEditingController(text: ""),
//     "Delivery Instructions": TextEditingController(text: "")
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _getDetails();
//   }
//
//   Future<void> _getDetails() async {
//     setState(() {
//       _controllers = {
//         "Label": TextEditingController(text: ""),
//         "Recipient Name": TextEditingController(text: ""),
//         "Street Address": TextEditingController(text: widget.place?.street),
//         "Apartment": TextEditingController(text: widget.place?.name),
//         "City": TextEditingController(text: widget.place?.locality),
//         "State": TextEditingController(text: widget.place?.administrativeArea),
//         "Postal Code": TextEditingController(text: widget.place?.postalCode),
//         "Country": TextEditingController(text: widget.place?.country),
//         "Phone Number": TextEditingController(text: ""),
//         "Delivery Instructions": TextEditingController(text: "")
//       };
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColor.backgroundColor,
//       appBar: AppBar(
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: Text("Your Profile",
//             style: TextStyle(color: Colors.black, fontSize: 16.sp)),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ..._controllers.keys.map((field) => Padding(
//                     padding: EdgeInsets.only(bottom: 16.h),
//                     child: _buildProfileField(
//                       label: field,
//                       controller: _controllers[field]!,
//                     ),
//                   )),
//               Row(
//                 children: [
//                   Checkbox(
//                     value: isDefault,
//                     onChanged: (value) => setState(() => isDefault = value!),
//                   ),
//                   Text("Set as Default"),
//                 ],
//               ),
//               SizedBox(height: 30.h),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50.h,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green.shade900,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                   ),
//                   onPressed: () async {
//                     if (_formKey.currentState!.validate()) {
//                       Map<String, dynamic> formData = {
//                         "name": _controllers["Label"]?.text ?? '',
//                         "recipientName":
//                             _controllers["Recipient Name"]?.text ?? '',
//                         "streetAddress":
//                             _controllers["Street Address"]?.text ?? '',
//                         "apartment": _controllers["Apartment"]?.text ?? '',
//                         "city": _controllers["City"]?.text ?? '',
//                         "state": _controllers["State"]?.text ?? '',
//                         "postalCode": _controllers["Postal Code"]?.text ?? '',
//                         "country": _controllers["Country"]?.text ?? '',
//                         "phoneNumber": _controllers["Phone Number"]?.text ?? '',
//                         "deliveryInstructions":
//                             _controllers["Delivery Instructions"]?.text ?? '',
//                         "isDefault":
//                             isDefault, // if controlled via checkbox/switch, keep as is
//                       };
//
//                       final res = await ApiService.postRequest(
//                           "auth/register/customer", {
//                         "idToken": widget.idToken.toString(),
//                         "fullName": widget.fullName.toString(),
//                         "contactNumber": widget.contactNumber.toString(),
//                         "address": widget.address.toString(),
//                         "profileImage": "https://example.com/image.jpg"
//                       });
//
//                       if (res["role"] == "Customer") {
//                         Map resF = {...res, "user": res};
//
//                         String actionString = jsonEncode(resF);
//                         await SharedPreferencesHelper.saveString(
//                             'userLookup', actionString); // Save a string value
//                         await ApiService.postRequest("address", formData);
//
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => FozoHomeScreen(),
//                           ),
//                         );
//                       }
//                     }
//                   },
//                   child: Text(
//                     "Add New Address",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileField({
//     required String label,
//     required TextEditingController controller,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
//         SizedBox(height: 6.h),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8.r),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   controller: controller,
//                   style: TextStyle(fontSize: 14.sp),
//                   decoration: const InputDecoration.collapsed(hintText: ""),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
