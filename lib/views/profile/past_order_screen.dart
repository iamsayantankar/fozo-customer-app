import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';

import '../../utils/http/api.dart';

class PastOrderScreen extends StatefulWidget {
  const PastOrderScreen({super.key});

  @override
  State<PastOrderScreen> createState() => _PastOrderScreenState();
}

class _PastOrderScreenState extends State<PastOrderScreen> {
  // Sample data to replicate multiple orders

  List _orders = [];

  @override
  void initState() {
    super.initState();
    // Fetch data once the widget is initialized
    getMyData();
  }

  Future<void> getMyData() async {
    final resOutlate = await ApiService.getRequest("order/customer");

    print("resOutlate");
    print(resOutlate);

    setState(() {
      _orders = resOutlate["orders"];
      print(_orders);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Past Orders",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    print(order);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Image, Details, Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  order["imageUrl"] ?? "https://bit.ly/bifulllogo",
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order["restaurantName"] ?? "Barbeque Nation, HSR",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Items loop
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (order["items"] as List<dynamic>).map((item) {
                        return Text(
                          "${item["quantity"]} X Bag of Price ${item["price"]}",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
              // Total Price
              Text(
                "₹ ${order["totalAmount"] ?? 0.00}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 8.h),

          // Delivery Address
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16.sp,
                color: Colors.green.shade900,
              ),
              SizedBox(width: 4.w),
              Text(
                "Delivery Address",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            order["deliveryAddress"] ??
                "Creative Residency | 24th Main Rd, IT...",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),

          // Delivery Time
          Row(
            children: [
              SvgPicture.asset(
                'assets/svg/timing_ok.svg',
                height: (16),
                width: (16),
              ),
              SizedBox(width: 4.w),
              Text.rich(
                TextSpan(
                  text: "Delivered at ",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                  ),
                  children: [
                    TextSpan(
                      text: order["deliveryTime"] ?? "10-11 PM",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700, // same color to match
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 8.h),

          // Rating Row
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Rate",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(width: 10),
              RatingBar.builder(
                initialRating: (order["rating"] ?? 3.5).toDouble(),
                minRating: 2.5,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 16.sp,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.green.shade900,
                ),
                onRatingUpdate: (rating) {
                  // TODO: Handle rating logic
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
