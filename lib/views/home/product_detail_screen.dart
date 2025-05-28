import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// Replace with your actual color constants import
import 'package:fozo_customer_app/core/constants/colour_constants.dart';

import '../../utils/constant/dimensions.dart';
import '../../utils/helper/shared_preferences_helper.dart';
import '../../utils/http/api.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';

class SurpriseBagDetailPage extends StatefulWidget {
  final int restaurantId;
  final String myAddress;
  final Map item;

  const SurpriseBagDetailPage({
    super.key,
    required this.restaurantId,
    required this.myAddress,
    required this.item,
  });

  @override
  State<SurpriseBagDetailPage> createState() => _SurpriseBagDetailPageState();
}

class _SurpriseBagDetailPageState extends State<SurpriseBagDetailPage> {
  bool _isExpanded = false; // For expanding "Look what other..."

  Map<String, dynamic> resData = {};
  Map<String, dynamic> resResData = {};

  List myCart = [];
  double totalPrice = 0;
  int totalBag = 0;

  @override
  void initState() {
    super.initState();
    // Fetch data once the widget is initialized

    getMyData();
  }

  Future<void> getMyData() async {
    print(widget.item);
    print("okijiugyth");

    final resOutlate = await ApiService.getRequest(
        "Search/Searchmysterybagwithrestaurantid?UserAddress=${widget.myAddress}&Page=1&PageSize=10&RestaurantId=${widget.restaurantId}");
    print("apidata");
    // print(resOutlate);
    // print(resOutlate);

    setState(() {
      resData = resOutlate;
      resResData = resOutlate["restaurants"] is List &&
              resOutlate["restaurants"].isNotEmpty == true
          ? resData["restaurants"][0]
          : {};
    });

    print("resResData");
    print(resResData);
    print("resResData");

    getReviewData(resOutlate);
  }

  Future<void> getReviewData(resResData) async {
    final resOutlate = await ApiService.getRequest(
        "FoodItemReviews/{foodItemId}/${resResData[0].myAddress}ratings");
    print("apidata");
    print(resOutlate);

    setState(() {
      resData = resOutlate;
      resResData = resOutlate["restaurants"] is List &&
              resOutlate["restaurants"].isNotEmpty == true
          ? resData["restaurants"][0]
          : {};
    });
  }

  void addToCart(Map selectItem) {
    print(selectItem);
    print(myCart);
    int index =
        myCart.indexWhere((item) => item["itemName"] == selectItem["packsize"]);
    if (index == -1) {
      myCart.add({
        "itemName": selectItem["packsize"],
        "quantity": 1,
        "foodItemId": selectItem["mystery_bag_id"],
        "price": selectItem["discountedPrice"],
        "isMysteryBag": true
      });
    } else {
      myCart[index]["quantity"] += 1;
      myCart[index]["price"] += selectItem["discountedPrice"];
    }
    setState(() {});
    totalPriceCal();
  }

  void removeFromCart(Map selectItem) {
    int index =
        myCart.indexWhere((item) => item["itemName"] == selectItem["packsize"]);
    if (index != -1) {
      myCart[index]["quantity"] -= 1;
      myCart[index]["price"] -= selectItem["discountedPrice"];
      if (myCart[index]["quantity"] <= 0) {
        myCart.removeAt(index);
      }
      setState(() {});
    }
    totalPriceCal();
  }

  void totalPriceCal() {
    totalPrice = 0;
    totalBag = 0;
    for (int i = 0; i < myCart.length; i++) {
      String itemName = myCart[i]["itemName"];
      int cartCount = myCart[i]["quantity"];

      int index = resData["restaurants"]
          .indexWhere((item) => item["packsize"] == itemName);
      double priceTag = resData["restaurants"][index]["discountedPrice"];
      totalPrice = totalPrice + (cartCount * priceTag);
      totalBag = totalBag + cartCount;
    }
    setState(() {});
  }

  double _widthP = 0.00;
  double _heightP = 0.00;

  @override
  Widget build(BuildContext context) {
    double widthP = Dimensions.myWidthThis(context);
    double heightP = Dimensions.myHeightThis(context);
    setState(() {
      _heightP = heightP;
      _widthP = widthP;
    });

    // Read from provider for total items & cost
    // final bagProvider = Provider.of<BagProvider>(context);
    // final totalBags = bagProvider.totalBags; // e.g. 2
    // final totalCost = bagProvider.totalCost; // e.g. 150

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,

      /// Show bottom container if at least 1 bag is added
      bottomNavigationBar: myCart.isNotEmpty ? _buildBottomBar() : null,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: (40 * heightP).h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16 * widthP),
                      child: SvgPicture.asset(
                        'assets/svg/left.svg',
                        height: (24 * heightP),
                        width: (24 * widthP),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16 * widthP),
                      child: SvgPicture.asset(
                        'assets/svg/share-forward-box-fill.svg',
                        height: (24 * heightP),
                        width: (24 * widthP),
                      ),
                    ),
                  ],
                ),
              ),

              // TOP IMAGE + ICONS
              Stack(
                children: [
                  // Large image at the top
                  Container(
                    margin: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white, // or any background color you want
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.item["imageUrl"],
                      height: 220 * _heightP.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ],
              ),

              // MAIN CONTENT
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (widget.item["foodType"] == "Both") ...[
                          SvgPicture.asset(
                            'assets/svg/veg.svg',
                            height: 24 * heightP,
                            width: 24 * widthP,
                          ),
                          SvgPicture.asset(
                            'assets/svg/non-veg.svg',
                            height: 24 * heightP,
                            width: 24 * widthP,
                          ),
                        ] else if (widget.item["foodType"] == "Veg") ...[
                          SvgPicture.asset(
                            'assets/svg/veg.svg',
                            height: 24 * heightP,
                            width: 24 * widthP,
                          ),
                        ] else ...[
                          SvgPicture.asset(
                            'assets/svg/non-veg.svg',
                            height: 24 * heightP,
                            width: 24 * widthP,
                          ),
                        ]
                      ],
                    ),
                    // Title + Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Restaurant Name
                        Expanded(
                          child: Text(
                            resResData["restaurantName"]?.toString() ?? "",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Rating + total reviews
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/rating_123321.svg',
                              height: (24 * heightP),
                              width: (24 * widthP),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              resResData["maxRating"]?.toString() ?? "",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // SizedBox(width: 4.w),
                            // Text(
                            //   "(251)",
                            //   style: TextStyle(
                            //     fontSize: 13.sp,
                            //     color: Colors.grey.shade600,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Subtitle
                    Text(
                      resResData["description"]?.toString() ?? "",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Text(
                          "Delivered by ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          "${resResData["deliveredBy"]}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),

                        // Badge
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(0xFF073228),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/shopping-1.svg',
                                height: (16),
                                width: (16),
                              ),
                              // Icon(Icons.shopping_bag,
                              //     color: Colors.yellowAccent, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "${resResData["mysteryBagsLeft"]} left",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        Spacer(),

                        // CO2 info
                      ],
                    ),

                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svg/cloud_line-1.svg',
                          height: (16),
                          width: (16),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "${resResData["totalCO2Saved"]}kg Co2 save",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 12),
                    // "What you could get" Title
                    Text(
                      "What you could get",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                    // "What you could get" Title
                    Text(
                      'Rescue Surprise Bag that may contain north Indian curry, Barbecue tikka, Biriyani or Indian Sweets.',
                      style: TextStyle(
                        color: Color(0xFF525866),
                        fontSize: 12,
                        fontFamily: 'Inter Display',
                      ),
                    ),

                    SizedBox(height: 18),

                    ListView.separated(
                      // Use a shrinkWrap to fit inside SingleChildScrollView
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (resData["restaurants"] as List?)?.length ?? 0,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = resData["restaurants"][index];
                        return _bagCard(item);
                      },
                    ),

                    SizedBox(height: 20.h),

                    // // Expandable Header: "Look what other people get in Surprise bag"
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() {
                    //       _isExpanded = !_isExpanded;
                    //     });
                    //   },
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         "Look what other people get in Surprise bag",
                    //         style: TextStyle(
                    //           fontSize: 16.sp,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.black87,
                    //         ),
                    //       ),
                    //       Icon(
                    //         _isExpanded
                    //             ? Icons.keyboard_arrow_up
                    //             : Icons.keyboard_arrow_down,
                    //         size: 20.sp,
                    //         color: Colors.black87,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 10.h),
                    //
                    // // Conditionally show rating + user review
                    // if (_isExpanded) ...[
                    //   // 1. The Container showing the "TOTAL RATING" header and the rating rows
                    //   Container(
                    //     padding: EdgeInsets.all(12.r),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(8.r),
                    //       border: Border.all(
                    //         color: Colors.grey.shade300,
                    //       ),
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         // HEADER ROW
                    //         Row(
                    //           children: [
                    //             Text(
                    //               "TOTAL RATING",
                    //               style: TextStyle(
                    //                 fontSize: 14.sp,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.grey.shade800,
                    //               ),
                    //             ),
                    //             const Spacer(),
                    //             Icon(
                    //               Icons.star,
                    //               color: const Color(0xFFFFB800),
                    //               size: 14.sp,
                    //             ),
                    //             SizedBox(width: 4.w),
                    //             Text(
                    //               "4.7/5",
                    //               style: TextStyle(
                    //                 fontSize: 13.sp,
                    //                 color: Colors.black87,
                    //               ),
                    //             ),
                    //             SizedBox(width: 4.w),
                    //             Text(
                    //               "(251)",
                    //               style: TextStyle(
                    //                 fontSize: 13.sp,
                    //                 color: Colors.grey.shade600,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         SizedBox(height: 12.h),
                    //         // RATING ROWS
                    //         _buildRatingRow("Food", 4.5),
                    //         SizedBox(height: 8.h),
                    //         _buildRatingRow("Value for money", 4.8),
                    //         SizedBox(height: 8.h),
                    //         _buildRatingRow("Food hygiene", 4.2),
                    //       ],
                    //     ),
                    //   ),
                    //
                    //   // Example user review
                    //   Container(
                    //     padding: EdgeInsets.all(12.r),
                    //     margin: EdgeInsets.symmetric(vertical: 8.h),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(8.r),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.black12,
                    //           blurRadius: 2.r,
                    //           offset: Offset(0, 1.h),
                    //         ),
                    //       ],
                    //     ),
                    //     child: Row(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         // User avatar
                    //         CircleAvatar(
                    //           radius: 24.r,
                    //           backgroundColor: Colors.grey.shade200,
                    //           child: ClipOval(
                    //             child: Image.network(
                    //               "https://via.placeholder.com/150",
                    //               fit: BoxFit.cover,
                    //               width: 48.w,
                    //               height: 48.h,
                    //             ),
                    //           ),
                    //         ),
                    //         SizedBox(width: 12.w),
                    //
                    //         // Right side: name, rating, comment, and time
                    //         Expanded(
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               // Top row: name + rating badge
                    //               Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   Text(
                    //                     "Amit",
                    //                     style: TextStyle(
                    //                       fontSize: 14.sp,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: Colors.black87,
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     padding: EdgeInsets.symmetric(
                    //                       horizontal: 6.w,
                    //                       vertical: 3.h,
                    //                     ),
                    //                     decoration: BoxDecoration(
                    //                       color: const Color(0xFFE9FFF1),
                    //                       borderRadius:
                    //                           BorderRadius.circular(12.r),
                    //                     ),
                    //                     child: Row(
                    //                       children: [
                    //                         Icon(
                    //                           Icons.star,
                    //                           color: Colors.green,
                    //                           size: 14.sp,
                    //                         ),
                    //                         SizedBox(width: 4.w),
                    //                         Text(
                    //                           "5.0",
                    //                           style: TextStyle(
                    //                             fontSize: 13.sp,
                    //                             color: Colors.black87,
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //               SizedBox(height: 4.h),
                    //               // Comment text
                    //               Text(
                    //                 "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                    //                 style: TextStyle(
                    //                   fontSize: 13.sp,
                    //                   color: Colors.grey.shade700,
                    //                 ),
                    //               ),
                    //               SizedBox(height: 8.h),
                    //               // Time stamp
                    //               Text(
                    //                 "2 days ago",
                    //                 style: TextStyle(
                    //                   fontSize: 12.sp,
                    //                   color: Colors.grey.shade500,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //
                    //   SizedBox(height: 20.h),
                    // ],
                    //
                    // SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A helper widget for the rating rows
  Widget _buildRatingRow(String label, double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Label on the left
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // Green progress bar in the middle
        Expanded(
          flex: 5,
          child: LinearProgressIndicator(
            value: rating / 5.0, // e.g. 4.5 -> 0.9
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 6.h,
          ),
        ),
        SizedBox(width: 8.w),

        // Numeric rating on the right
        Text(
          rating.toStringAsFixed(1), // e.g. "4.5"
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// The bottom bar container: "Reserve now - ₹xxx" + "x Surprise bags added"
  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The main button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // allows more space if needed
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.r)),
                  ),
                  builder: (BuildContext context) {
                    return _buildSurpriseSheet(context);
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF073228),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                "Reserve now - ₹$totalPrice",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          // The subtitle: "x Surprise bags added"
          Text(
            "$totalBag Surprise bags added",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bagCard(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.only(bottom: 8.h),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(8.r),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black12,
      //       blurRadius: 2.r,
      //       offset: Offset(0, 1.h),
      //     ),
      //   ],
      // ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image on the left
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: item["imageUrl"] ?? "",
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          SizedBox(width: 10.w),

          // Middle text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["packsize"] ?? "",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item["description"] ?? "",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '₹${item["discountedPrice"]} ',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextSpan(
                        text: 'worth ₹${item["originalPrice"]}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Right side: either "ADD +" or quantity selector
          myCart.firstWhere((e) => e["itemName"] == item["packsize"],
                      orElse: () => {"quantity": 0})["quantity"] ==
                  0
              ? _buildAddButton(item)
              : _buildQuantitySelector(item),
        ],
      ),
    );
  }

  Widget _buildAddButton(Map<String, dynamic> item) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.green.shade900),
      //   borderRadius: BorderRadius.circular(12.r),
      // ),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: ShapeDecoration(
        color: Color(0x38EEFFA8),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFD4ED6D)),
          borderRadius: BorderRadius.circular(17),
        ),
      ),

      child: GestureDetector(
        onTap: () async {
          String userLookup =
              await SharedPreferencesHelper.getString("userLookup") ?? "";

          if (userLookup != "") {
            addToCart(item);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ADD",
              style: TextStyle(
                color: Colors.green.shade900,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.add,
              size: 18.sp,
              color: Colors.green.shade900,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: ShapeDecoration(
        color: Color(0x38EEFFA8),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFD4ED6D)),
          borderRadius: BorderRadius.circular(17),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // minus
          GestureDetector(
            onTap: () async {
              String userLookup =
                  await SharedPreferencesHelper.getString("userLookup") ?? "";

              if (userLookup != "") {
                removeFromCart(item);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
            child: Icon(
              Icons.remove,
              size: 18.sp,
              color: Colors.green.shade900,
            ),
          ),
          SizedBox(width: 8.w),

          // quantity
          Text(
            myCart
                .firstWhere((e) => e["itemName"] == item["packsize"],
                    orElse: () => {"quantity": 0})["quantity"]
                .toString(),
            style: TextStyle(
              color: Colors.green.shade900,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8.w),

          // plus
          GestureDetector(
            onTap: () async {
              String userLookup =
                  await SharedPreferencesHelper.getString("userLookup") ?? "";

              if (userLookup != "") {
                addToCart(item);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
            child: Icon(
              Icons.add,
              size: 18.sp,
              color: Colors.green.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurpriseSheet(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        // Make the sheet wrap its content
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4.h,
            width: 50.w,
            // color: Colors.black.withOpacity(0.2), // 20% opacity
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                  8.r), // you can change 8.r to your desired radius
            ),
          ),
          SizedBox(height: 16.h),

          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.w,
              ),
              borderRadius: BorderRadius.circular(12.r),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(16.r),
            child: Padding(
              padding: EdgeInsets.only(left: 12.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align content to the left
                children: [
                  SvgPicture.asset(
                    'assets/svg/shopping.svg',
                    height: (40),
                    width: (40),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "Your bag will be a surprise",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "We wish we could tell you what exactly will be in your Surprise Bag — but it's always a surprise! The store will fill it with a selection of their unsold items.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Add: End Border - In a box border, all in one Box -chatgpt, update this
          // "Got It!" button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                // 1. Dismiss bottom sheet
                Navigator.pop(context);

                // 2. Navigate to CheckoutPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(
                      restaurantId: widget.restaurantId,
                      myAddress: widget.myAddress,
                      resData: resData,
                      myCart: myCart,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF073228),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                "Got It!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSurpriseSheet3(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.w,
          ),
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon at the top
            Icon(
              Icons.shopping_bag,
              color: Colors.green.shade900,
              size: 40.sp,
            ),
            SizedBox(height: 16.h),

            // Title
            Text(
              "Your bag will be a surprise",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),

            // Description
            Text(
              "We wish we could tell you what exactly will be in your Surprise Bag — but it's always a surprise! The store will fill it with a selection of their unsold items.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 20.h),

            // "Got It!" button
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(
                        restaurantId: widget.restaurantId,
                        myAddress: widget.myAddress,
                        resData: resData,
                        myCart: myCart,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  "Got It!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSurpriseSheet2(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75, // 75% of screen height
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // for (int i = 0; i < 15; i++) ...[
              Icon(
                Icons.shopping_bag,
                color: Colors.green.shade900,
                size: 40.sp,
              ),
              SizedBox(height: 16.h),
              // ],
              Text(
                "Your bag will be a surprise",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "We wish we could tell you what exactly will be in your Surprise Bag — but it's always a surprise! The store will fill it with a selection of their unsold items.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          restaurantId: widget.restaurantId,
                          myAddress: widget.myAddress,
                          resData: resData,
                          myCart: myCart,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    "Got It!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
