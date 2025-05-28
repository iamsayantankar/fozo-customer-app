import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:uuid/uuid.dart';

import '../../utils/helper/shared_preferences_helper.dart';
import '../../utils/http/api.dart';
import '../../widgets/custom_button_widget.dart';
import '../payment/payment_screen.dart';

class CheckoutPage extends StatefulWidget {
  final int restaurantId;
  final String myAddress;
  final List myCart;
  final Map resData;

  const CheckoutPage({
    super.key,
    required this.restaurantId,
    required this.myAddress,
    required this.myCart,
    required this.resData,
  });
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  double totalItemPrice = 0;
  int totalBag = 0;

  var uuid = Uuid();
  String cartId = "";

  List _addresses = [];
  Map _selectAddress = {};

  Future<void> _getData() async {
    final resAddress = await ApiService.getRequest("address");
    _addresses = resAddress["data"];
    _selectAddress = _addresses.firstWhere(
      (addr) => addr["isDefault"] == true,
      orElse: () => {},
    );

    setState(() {}); // Refresh the UI if inside a StatefulWidget
  }

  @override
  void initState() {
    super.initState();
    // Fetch data once the widget is initialized
    cartId = uuid.v4();
    getMyData();
    _getData();
  }

  void getMyData() {
    totalItemPrice = 0;
    totalBag = 0;
    for (int i = 0; i < widget.myCart.length; i++) {
      String itemName = widget.myCart[i]["itemName"];
      int cartCount = widget.myCart[i]["quantity"];
      int index = widget.resData["restaurants"]
          .indexWhere((item) => item["packsize"] == itemName);
      double priceTag = widget.resData["restaurants"][index]["discountedPrice"];
      totalItemPrice = totalItemPrice + (cartCount * priceTag);
      totalBag = totalBag + cartCount;
    }
    setState(() {});
  }

  void addToCart(Map selectItem) {
    int index = widget.myCart
        .indexWhere((item) => item["itemName"] == selectItem["packsize"]);
    if (index == -1) {
      widget.myCart.add({
        "itemName": selectItem["packsize"],
        "quantity": 1,
        "foodItemId": selectItem["mystery_bag_id"],
        "price": selectItem["discountedPrice"],
        "isMysteryBag": true
      });
    } else {
      widget.myCart[index]["quantity"] += 1;
      widget.myCart[index]["price"] += selectItem["discountedPrice"];
    }
    setState(() {});
    getMyData();
  }

  void removeFromCart(Map selectItem) {
    int index = widget.myCart
        .indexWhere((item) => item["itemName"] == selectItem["packsize"]);
    if (index != -1) {
      widget.myCart[index]["quantity"] -= 1;
      widget.myCart[index]["price"] -= selectItem["discountedPrice"];

      if (widget.myCart[index]["quantity"] <= 0) {
        widget.myCart.removeAt(index);
      }
      setState(() {});
    }
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryCharge = 0.0;
    final handlingCharge = 0.0;

    // final subTotal = bagProvider.totalCost; // sum of item.price * quantity
    // final grandTotal = subTotal + deliveryCharge + handlingCharge;

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        // If you want a back arrow, or you can omit
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Checkout",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // // CO2 Saved Message
              //
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 90, vertical: 3),
              //   decoration: BoxDecoration(
              //     color: Color(0xFFFBFFEC),
              //     borderRadius: BorderRadius.only(
              //       bottomLeft: Radius.circular(12),
              //       bottomRight: Radius.circular(12),
              //     ),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Color(0x05000000),
              //         blurRadius: 2,
              //         offset: Offset(0, 2),
              //         spreadRadius: 0,
              //       )
              //     ],
              //   ),
              //   child: Row(
              //     // mainAxisSize: MainAxisSize.min,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       SvgPicture.asset(
              //         'assets/svg/cloud_line-1.svg',
              //         height: (16),
              //         width: (16),
              //       ),
              //       Text.rich(
              //         TextSpan(
              //           children: [
              //             TextSpan(
              //               text: 'You saved',
              //               style: TextStyle(
              //                 color: Color(0xFF055F19),
              //                 fontSize: 12,
              //                 fontFamily: 'Inter Display',
              //                 height: 0,
              //               ),
              //             ),
              //             TextSpan(
              //               text: ' 0.7kg',
              //               style: TextStyle(
              //                 color: Color(0xFF055F19),
              //                 fontSize: 12,
              //                 fontFamily: 'Inter Display',
              //                 fontWeight: FontWeight.bold, // Bold added here
              //                 height: 0,
              //               ),
              //             ),
              //             TextSpan(
              //               text: ' Co2',
              //               style: TextStyle(
              //                 color: Color(0xFF055F19),
              //                 fontSize: 12,
              //                 fontFamily: 'Inter Display',
              //                 fontWeight: FontWeight.bold, // Bold added here
              //                 height: 0,
              //               ),
              //             ),
              //             TextSpan(
              //               text: '  on this order',
              //               style: TextStyle(
              //                 color: Color(0xFF055F19),
              //                 fontSize: 12,
              //                 fontFamily: 'Inter Display',
              //                 height: 0,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              SizedBox(height: 16.h),

              // "Cart" heading

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2.r,
                      offset: Offset(0, 1.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cart",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 12),
                    ListView.separated(
                      // Use a shrinkWrap to fit inside SingleChildScrollView
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.resData["restaurants"]!.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = widget.resData["restaurants"][index];
                        return _buildCartItemRow(item);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              Container(
                padding: EdgeInsets.all(12.r),
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2.r,
                      offset: Offset(0, 1.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green.shade900,
                          size: 18.sp,
                        ),
                        SizedBox(width: 6.w),

                        // Wrap the whole Column with Expanded instead
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Delivery Address",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "${_selectAddress["name"]} | ${_selectAddress["apartment"]}, ${_selectAddress["city"]}, ${_selectAddress["state"]}, ${_selectAddress["postalCode"]} | Recipient Name: ${_selectAddress["recipientName"]} | Phone No: ${_selectAddress["phoneNumber"]}",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 6.w),

                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            500), // scrollable if more addresses
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Select Delivery Address",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: _addresses.length,
                                            itemBuilder: (context, index) {
                                              final item = _addresses[index];
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectAddress = item;
                                                  });
                                                  Navigator.pop(
                                                      context); // close popup
                                                },
                                                child: Card(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    side: BorderSide(
                                                      color:
                                                          item["isDefault"] ==
                                                                  true
                                                              ? Colors.green
                                                              : Colors.grey
                                                                  .shade300,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  elevation: 3,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(12),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.home,
                                                              color: Colors
                                                                  .green
                                                                  .shade800,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              item["name"] ??
                                                                  "",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            if (item[
                                                                    "isDefault"] ==
                                                                true) ...[
                                                              SizedBox(
                                                                  width: 6),
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .green
                                                                      .shade50,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Text(
                                                                  "Default",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .green
                                                                        .shade800,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              )
                                                            ]
                                                          ],
                                                        ),
                                                        SizedBox(height: 6),
                                                        Text(
                                                          "${item["apartment"]}, ${item["streetAddress"]}, ${item["city"]}, ${item["state"]} - ${item["postalCode"]}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          "Phone: ${item["phoneNumber"]}",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        CustomButton(
                                            text: "Add New Address",
                                            onPressed: () {}),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            "Change",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Color(0xFF1C4D1E),
                              fontWeight: FontWeight.bold, // 👈 Add this
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/timer-flash-line.svg',
                          height: (18),
                          width: (18),
                        ),
                        SizedBox(width: 6.w),

                        // Wrap the whole Column with Expanded instead
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Delivered by ",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: 'Inter Display',
                                      ),
                                    ),
                                    TextSpan(
                                      text: "10-11 PM",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Will notify you 20 minutes before the delivery time.',
                                style: TextStyle(
                                  color: Color(0xFF525866),
                                  fontSize: 12,
                                  fontFamily: 'Inter Display',
                                  height: 0.11,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delivery Address

              SizedBox(height: 20.h),

              // Bill Details

              // Bill details container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2.r,
                      offset: Offset(0, 1.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bill Details",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black,
                          size: 18.sp,
                        ),
                      ],
                    ),

                    SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 12),
                    _buildBillRow(
                      "Sub total",
                      "₹$totalItemPrice",
                      isBold: true,
                    ),
                    SizedBox(height: 4.h),
                    _buildBillRow(
                      "Delivery charge",
                      "₹$deliveryCharge",
                      isBold: true,
                    ),
                    SizedBox(height: 4.h),
                    _buildBillRow(
                      "Handling charge",
                      "₹$handlingCharge",
                      isBold: true,
                    ),
                    SizedBox(height: 4.h),
                    // Divider(color: Colors.grey.shade300, thickness: 1),
                    // SizedBox(height: 8.h),
                    _buildBillRow(
                      "Grand total",
                      "₹${totalItemPrice + deliveryCharge + handlingCharge}",
                      isBold: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // "Process to pay" Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () async {
                    print("object");
                    if (_selectAddress.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("No Address Selected"),
                            content: Text(
                                "Please select an address before confirming."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    String? userLookUpString =
                        await SharedPreferencesHelper.getString("userLookup");

                    int userId;
                    if (userLookUpString != null) {
                      Map userLookup = jsonDecode(userLookUpString);
                      print(userLookup);
                      print(userLookup["user"]);
                      userId = userLookup["user"]["userId"] ??
                          userLookup["user"]["user_id"];

                      String email = userLookup["user"]["email"];

                      // return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentMethodPage(
                              cartId: cartId,
                              selectAddress: _selectAddress,
                              totalPayPrice: totalItemPrice +
                                  handlingCharge +
                                  deliveryCharge,
                              customerId: userId.toString(),
                              email: email.toString(),
                              restaurantId: widget.restaurantId.toString(),
                              cartItems: widget.myCart),
                        ),
                      );
                    }

                    return;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF073228),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    "Process to pay",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // A helper row for the Bill details
  Widget _buildBillRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black87,
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Build each item in the quantity
  Widget _buildCartItemRow(item) {
    int count = widget.myCart.firstWhere(
        (e) => e["itemName"] == item["packsize"],
        orElse: () => {"quantity": 0})["quantity"];
    if (count == 0) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }

    print(item);
    print("itemitemitem");

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: item["imageUrl"],
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

          // Middle texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item["foodType"] == "Both") ...[
                      SvgPicture.asset(
                        'assets/svg/veg.svg',
                        height: 16,
                        width: 16,
                      ),
                      SvgPicture.asset(
                        'assets/svg/non-veg.svg',
                        height: 16,
                        width: 16,
                      ),
                    ] else if (item["foodType"] == "Veg") ...[
                      SvgPicture.asset(
                        'assets/svg/veg.svg',
                        height: 16,
                        width: 16,
                      ),
                    ] else ...[
                      SvgPicture.asset(
                        'assets/svg/non-veg.svg',
                        height: 16,
                        width: 16,
                      ),
                    ]
                  ],
                ),
                Text(
                  item["packsize"] ?? "",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item["description"] ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "₹${item["discountedPrice"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          color: Colors.black87,
                        ),
                      ),
                      TextSpan(
                        text: " worth ₹${item["originalPrice"]}",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Quantity selector
          Container(
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
                  onTap: () {
                    removeFromCart(item);
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
                  "$count",
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),

                // plus
                GestureDetector(
                  onTap: () {
                    addToCart(item);
                  },
                  child: Icon(
                    Icons.add,
                    size: 18.sp,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
