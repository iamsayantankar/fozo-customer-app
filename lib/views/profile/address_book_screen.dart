import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:fozo_customer_app/widgets/custom_button_widget.dart';

import '../../utils/http/api.dart';
import 'add_location.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  // Sample addresses to display
  List _addresses = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    final resAddress = await ApiService.getRequest("address");
    print(resAddress);
    _addresses = resAddress["data"];
    setState(() {}); // Refresh the UI if inside a StatefulWidget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,

      // 1) AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Address Book",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 2) Body
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            // The address cards
            Expanded(
              child: ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final item = _addresses[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the detail page
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => EditDeliveryLocationScreen(
                      //           addressId: item["addressId"].toString())
                      //       // If you need to pass data, you can pass `item` or other details here
                      //       ),
                      // );
                    },
                    child: _buildAddressCard(item),
                  );
                },
              ),
            ),

            // "+ Add Address" button at the bottom
            SizedBox(height: 8.h),
            CustomButton(
                text: "+ Add Address",
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const AddNewDeliveryLocationScreen(),
                    ),
                  );
                }),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // A helper to build each address card
  Widget _buildAddressCard(Map<String, dynamic> item) {
    final isDefault = item["isDefault"] == true;

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(10.r),
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
              // Row with name and optional DEFAULT badge
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item["name"] ?? "",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0, width: 5),
                  if (isDefault)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green, width: 1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "DEFAULT",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                "${item["apartment"]} ${item["streetAddress"]} ${item["city"]} ${item["state"]} ${item["postalCode"]}",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Phone Number: ${item["phoneNumber"]}",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),

        // Delete button (top-right)
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
            onPressed: () {
              _confirmDelete(context, item);
            },
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Address"),
          content: Text("Are you sure you want to delete this address?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the popup

                await ApiService.deleteRequest("address/${item["addressId"]}");

                _getData();
              },
            ),
          ],
        );
      },
    );
  }
}
