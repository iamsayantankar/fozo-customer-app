// fozo_home_screen.dart
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:fozo_customer_app/views/home/UpdateDeliveryLocationScreen.dart';
import 'package:fozo_customer_app/views/profile/profile_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../provider/home_provider.dart';
import '../../utils/constant/dimensions.dart';
import '../../utils/helper/shared_preferences_helper.dart';
// import '../../utils/http/api.dart';
import '../../utils/http/api.dart';
import '../auth/login_screen.dart';
import 'product_detail_screen.dart';

class FozoHomeScreen extends StatefulWidget {
  const FozoHomeScreen({Key? key}) : super(key: key);

  @override
  State<FozoHomeScreen> createState() => _FozoHomeScreenState();
}

class _FozoHomeScreenState extends State<FozoHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic> userLookupJson = {};

  Map<String, dynamic> topRatedRestaurent = {
    "restaurants": [],
    "totalCount": 3,
    "page": 1,
    "pageSize": 3,
    "totalPages": 0
  };
  List topRatedRestaurentFiltered = [];

  Map<String, dynamic> availableRestaurent = {
    "restaurants": [],
    "totalCount": 0,
    "page": 1,
    "pageSize": 0,
    "totalPages": 0
  };
  List availableRestaurentFiltered = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    // Fetch data once the widget is initialized
    context.read<FozoHomeProvider>().fetchHomeData();
    getMyData();
    getLocationData();
  }

  Future<void> getMyData() async {
    print("kkk");

    String? userLookupString =
        await SharedPreferencesHelper.getString("userLookup");
    if (userLookupString != null) {
      userLookupJson = jsonDecode(userLookupString);
      setState(() {});
    } else {
      print("No data found!");
    }
  }

  void _onSearchChanged() {
    String searchValue = _searchController.text.toLowerCase();
    setState(() {
      topRatedRestaurentFiltered =
          topRatedRestaurent["restaurants"].where((restaurant) {
        String name = restaurant["restaurantName"]?.toLowerCase() ?? "";
        return name.contains(searchValue);
      }).toList();

      availableRestaurentFiltered =
          availableRestaurent["restaurants"].where((restaurant) {
        String name = restaurant["restaurantName"]?.toLowerCase() ?? "";
        return name.contains(searchValue);
      }).toList();
    });
  }

  String locationMessage = "";
  String addressMessage = "Loading...";

  /// Function to get the current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// Function to get address from coordinates
  Future<String> getAddressFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      Placemark place = placemarks[0];

      return "${place.name}, ${place.street}, ${place.locality}, ${place.country}";
    } catch (e) {
      return "Could not get address";
    }
  }

  /// Function to get and display the location & address
  void getLocationData() async {
    try {
      Position position = await getCurrentPosition();
      String address = await getAddressFromCoordinates(
          position.latitude, position.longitude);

      setState(() {
        locationMessage =
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
        addressMessage = address;
      });

      final resOutlate = await ApiService.getRequest(
          "Search/Searchmysterybagwithoutlet?UserAddress=$address&Page=1&PageSize=10");

      setState(() {
        availableRestaurent = resOutlate;
      });

      final resRatingWise = await ApiService.getRequest(
          "Search/Searchmysterybagratingwise?UserAddress=$address&Page=1&PageSize=10");

      setState(() {
        topRatedRestaurent = resRatingWise;
      });

      _onSearchChanged();
    } catch (e) {
      setState(() {
        locationMessage = "Error: $e";
        addressMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double widthP = Dimensions.myWidthThis(context);
    double heightP = Dimensions.myHeightThis(context);

    final provider = context.watch<FozoHomeProvider>();

    return WillPopScope(
      onWillPop: () {
        // This acts like onBackPressed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Back not allowed')),
        );
        return Future.value(false); // ✅ Wrap in Future
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor,
        body: SafeArea(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.hasError
                  ? Center(
                      child: Text(
                        "Error: ${provider.errorMessage}",
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 250.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFEEFFA9), // top color
                                      Color(0xFFD4ED6D), // bottom color
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30.r),
                                    bottomRight: Radius.circular(30.r),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (20 * widthP).w,
                                  vertical: (20 * heightP).h,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Address Card
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Location Icon
                                        Icon(
                                          Icons.location_on,
                                          color: Color(0xFF073228),
                                          size: (24 * heightP).sp,
                                        ),
                                        SizedBox(width: 8.w),

                                        // Expanded Column for address
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  final result =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UpdateLocationForHome(), // Pass data here if needed
                                                    ),
                                                  );

                                                  // Handle the returned result
                                                  if (result != null) {
                                                    print(
                                                        "Returned value: $result");
                                                    // Update state or do something with `result`
                                                    setState(() {
                                                      addressMessage = result;
                                                    });

                                                    final resOutlate =
                                                        await ApiService.getRequest(
                                                            "Search/Searchmysterybagwithoutlet?UserAddress=$result&Page=1&PageSize=10");

                                                    setState(() {
                                                      availableRestaurent =
                                                          resOutlate;
                                                    });

                                                    final resRatingWise =
                                                        await ApiService.getRequest(
                                                            "Search/Searchmysterybagratingwise?UserAddress=$result&Page=1&PageSize=10");

                                                    setState(() {
                                                      topRatedRestaurent =
                                                          resRatingWise;
                                                    });

                                                    _onSearchChanged();
                                                  }

                                                  // Your click action here, e.g., open a location picker or show a dialog
                                                  print(
                                                      "Current Location tapped");
                                                },
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "Current Location",
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Icon(
                                                      Icons.keyboard_arrow_down,
                                                      color: Color(0xFF073228),
                                                      size: 20.sp,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: (4 * heightP).h),
                                              Text(
                                                addressMessage,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: Color(0xFF073228),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Small horizontal gap before avatar
                                        SizedBox(width: (6 * widthP).w),

                                        // Circular Avatar (e.g., user profile)
                                        GestureDetector(
                                          onTap: () async {
                                            String userLookup =
                                                await SharedPreferencesHelper
                                                        .getString(
                                                            "userLookup") ??
                                                    "";

                                            if (userLookup != "") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ProfileHomeScreen()),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginScreen()),
                                              );
                                            }
                                          },
                                          child: CircleAvatar(
                                            radius: 20.r,
                                            backgroundColor: Color(
                                                0xFF91A14C), // Updated background color
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 24 * heightP,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 20.h),

                                    // Search Bar
                                    Container(
                                      height: (40 * heightP).h,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: Color(0xFF073228),
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: TextField(
                                              controller: _searchController,
                                              decoration: InputDecoration(
                                                isCollapsed:
                                                    true, // Fixes vertical alignment
                                                hintText: "Search...",
                                                hintStyle: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.black54,
                                                ),
                                                border: InputBorder.none,
                                              ),
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 30
                                    .h, // Adjust for spacing above the bottom edge
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/svg/fozo_home.svg',
                                    height: (65 * heightP),
                                    width: (40 * widthP),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: (6 * heightP).h),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: (16 * widthP).w,
                              vertical: (6 * heightP).h,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Top rated near you",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                // A small gap between the text and the line
                                SizedBox(width: (8 * widthP).w),
                                // Expanded widget to take up remaining space
                                Expanded(
                                  child: Container(
                                    // Adjust height/thickness and color as desired
                                    height: (1.5 * heightP).h,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: (15 * heightP).h),
                          SizedBox(
                            height: (255 * heightP),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: topRatedRestaurentFiltered.length,
                              itemBuilder: (context, index) {
                                final item = topRatedRestaurentFiltered[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to the detail page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SurpriseBagDetailPage(
                                          restaurantId:
                                              topRatedRestaurentFiltered[index]
                                                  ["restaurantId"],
                                          myAddress: addressMessage,
                                          item: item,
                                        ),
                                        // If you need to pass data, you can pass `item` or other details here
                                      ),
                                    );
                                  },
                                  child: _buildHorizontalCard(item),
                                );
                              },
                            ),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.all((16 * widthP).w),
                          //   child: Stack(
                          //     children: [
                          //       // Main Container
                          //       Container(
                          //         width: double.infinity,
                          //         padding: EdgeInsets.all(16.r),
                          //         decoration: BoxDecoration(
                          //           color: const Color(
                          //               0xFFF6FCEB), // Pale greenish
                          //           borderRadius: BorderRadius.circular(12.r),
                          //         ),
                          //         child: Column(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: [
                          //             // Main Promo Text
                          //             Text(
                          //               "Flat ₹500 off on first order",
                          //               style: TextStyle(
                          //                 fontSize: 16.sp,
                          //                 fontWeight: FontWeight.bold,
                          //                 color: Colors.black87,
                          //               ),
                          //             ),
                          //             SizedBox(height: (8 * heightP).h),
                          //
                          //             // Row for code + copy icon
                          //             Row(
                          //               mainAxisSize: MainAxisSize.min,
                          //               children: [
                          //                 Text(
                          //                   "NEW500",
                          //                   style: TextStyle(
                          //                     fontSize: 14.sp,
                          //                     fontWeight: FontWeight.bold,
                          //                     color: Colors.black87,
                          //                   ),
                          //                 ),
                          //                 SizedBox(width: (8 * heightP).w),
                          //
                          //                 // Copy icon
                          //                 GestureDetector(
                          //                   onTap: () async {
                          //                     // Copy the code to clipboard
                          //                     await Clipboard.setData(
                          //                       const ClipboardData(
                          //                           text: "NEW500"),
                          //                     );
                          //
                          //                     // Optional: Show a small feedback (snackbar)
                          //                     ScaffoldMessenger.of(context)
                          //                         .showSnackBar(
                          //                       const SnackBar(
                          //                         content: Text(
                          //                             "Code copied to clipboard"),
                          //                       ),
                          //                     );
                          //                   },
                          //                   child: Icon(
                          //                     Icons.copy,
                          //                     size: 16.sp,
                          //                     color: Colors.black87,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //
                          //       // "fozo" watermark in the bottom-right
                          //       Positioned(
                          //         bottom: 0.h,
                          //         right: 16.w,
                          //         child: Text(
                          //           "fozo",
                          //           style: TextStyle(
                          //             fontSize: 40.sp,
                          //             color: Colors.black.withOpacity(0.05),
                          //             fontWeight: FontWeight.bold,
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "All available outlet near you",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                // A small gap between the text and the line
                                SizedBox(width: 8.w),
                                // Expanded widget to take up remaining space
                                Expanded(
                                  child: Container(
                                    // Adjust height/thickness and color as desired
                                    height: 1.h,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.separated(
                            // Use a shrinkWrap to fit inside SingleChildScrollView
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: availableRestaurentFiltered.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final item = availableRestaurentFiltered[index];
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to the detail page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SurpriseBagDetailPage(
                                        restaurantId:
                                            availableRestaurentFiltered[index]
                                                ["restaurantId"],
                                        myAddress: addressMessage,
                                        item: item,
                                      ),
                                      // If you need to pass data, you can pass `item` or other details here
                                    ),
                                  );
                                },
                                child: _buildVerticalCard(item),
                              );
                            },
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  // Widget for horizontal "Top Rated" card
  Widget _buildHorizontalCard(item) {
    double widthP = Dimensions.myWidthThis(context);
    double heightP = Dimensions.myHeightThis(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        // bottom: (7*heightP).h
      ),
      child: SizedBox(
        width: 160.w,
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Overlays
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.r),
                ),
                child: Stack(
                  children: [
                    // Main Image
                    CachedNetworkImage(
                      imageUrl: item["imageUrl"] ?? "",
                      height: (148 * heightP),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),

                    // "2 left" in bottom-left
                    Positioned(
                      bottom: 4.h,
                      left: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        // decoration: BoxDecoration(
                        //   color: Colors.white,
                        //   borderRadius: BorderRadius.circular(4.r),
                        // ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/bag.svg',
                              height: (12 * heightP),
                              width: (16 * widthP),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "${item["mysteryBagsLeft"]} left",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold, // Make text bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Star rating in bottom-right
                    Positioned(
                      bottom: 4.h,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        // decoration: BoxDecoration(
                        //   color: Colors.white,
                        //   borderRadius: BorderRadius.circular(4.r),
                        // ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/rating_123321.svg',
                              height: (16 * heightP),
                              width: (16 * widthP),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              item["maxRating"].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold, // Make text bold
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Info
              Padding(
                padding: EdgeInsets.all((7 * heightP).r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //veg-non veg
                    SvgPicture.asset(
                      'assets/svg/veg.svg',
                      height: (16 * heightP),
                      width: (16 * widthP),
                    ),

                    // Title
                    Text(
                      item["restaurantName"],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // SizedBox(height: (4*heightP).h),

                    // Price
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹ ',
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          TextSpan(
                            text: "${item["discountedPrice"]} ",
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          TextSpan(
                            text: 'worth ',
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                          TextSpan(
                            text: '₹ ',
                            // style: TextStyle(fontSize: 12.sp, color: Colors.grey, decoration: TextDecoration.lineThrough),
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                          TextSpan(
                            text: item["originalPrice"].toString(),
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // SizedBox(height: (4*heightP).h),

                    // Delivery Time
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Delivered by\n',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          TextSpan(
                            text: item["deliveredBy"],
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for vertical "Outlet" card
  Widget _buildVerticalCard(item) {
    double widthP = Dimensions.myWidthThis(context);
    double heightP = Dimensions.myHeightThis(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * widthP),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        elevation: 2, // Slight shadow for a card-like effect
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image + Overlays
            ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(10.r),
              ),
              child: Stack(
                children: [
                  // Main Image
                  CachedNetworkImage(
                    imageUrl: item["imageUrl"] ?? "",
                    height: (148 * heightP),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),

                  // "5 left" badge (top-left)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      // decoration: BoxDecoration(
                      //   color: Color(0x22FFFFFF),
                      //   borderRadius: BorderRadius.circular(9),
                      //   border: Border.all(
                      //     color: Colors.white, // Lime color border
                      //     width: 1.0, // Adjust border thickness if needed
                      //   ),
                      // ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svg/bag.svg',
                            height: (12 * heightP),
                            width: (12 * widthP),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "${item["mysteryBagsLeft"]} left",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold, // Make text bold
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // "1kg Co2 save" badge (top-right)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: Colors.white, // Lime color border
                          width: 1.0, // Adjust border thickness if needed
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svg/cloud_line.svg',
                            height: (16 * heightP),
                            width: (16 * widthP),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "${item["totalCO2Saved"]}kg Co2 save",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Info
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //veg-non veg
                  SvgPicture.asset(
                    'assets/svg/veg.svg',
                    height: (16 * heightP),
                    width: (16 * widthP),
                  ),

                  // First row: Title + Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item["restaurantName"], // e.g., "Boss Burger"
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svg/rating_123321.svg',
                            height: (16 * heightP),
                            width: (16 * widthP),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            item["maxRating"]
                                .toString(), // or item.rating if available
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Subtitle / Description
                  Text(
                    "American Burger Surprise bag", // or item.subtitle
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₹ ',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: '${item["discountedPrice"]} ',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            TextSpan(
                              text: 'worth ',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey),
                            ),
                            TextSpan(
                              text: '₹ ',
                              // style: TextStyle(fontSize: 12.sp, color: Colors.grey, decoration: TextDecoration.lineThrough),
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey),
                            ),
                            TextSpan(
                              text: item["originalPrice"].toString(),
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // SizedBox(height: (4*heightP).h),

                      // Delivery Time
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Delivered by ',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            TextSpan(
                              text: item["deliveredBy"],
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Delivery time
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
