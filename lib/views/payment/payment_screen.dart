import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Replace with your actual color constants import
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:fozo_customer_app/views/payment/payment_complete.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../utils/http/api.dart';

class PaymentMethodPage extends StatefulWidget {
  final double totalPayPrice;
  final String cartId;
  final String email;
  final String customerId;
  final String restaurantId;
  final Map selectAddress;
  final List cartItems;

  const PaymentMethodPage({
    super.key,
    required this.cartId,
    required this.email,
    required this.totalPayPrice,
    required this.selectAddress,
    required this.customerId,
    required this.restaurantId,
    required this.cartItems,
  });
  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  late Razorpay _razorpay;

  Map _orderDetails = {};
  Map _razorpayOrderDetails = {};

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    createPaymentPage();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print({"success1": response.paymentId.toString()});

    final option = {
      "OrderId": _orderDetails["orderId"],
      "TransactionId": response.paymentId.toString()
    };

    final res = await ApiService.putRequest("order/successtransaction", option);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentComplete(),
      ),
    );
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    final option = {
      "OrderId": _orderDetails["orderId"],
      "TransactionId": _razorpayOrderDetails["id"].toString()
    };
    final res = await ApiService.putRequest("order/faluretransaction", option);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    print(123321123321);
    print(response);
    print(response.walletName);
  }

  Future<void> createPaymentPage() async {
    final resCustomer = await ApiService.getRequest("profile/customer");
    DateTime now = DateTime.now();

    String formatted = now.toIso8601String().split('.').first;

    final option = {
      "customerId": resCustomer["customer_id"],
      "restaurantId": widget.restaurantId.toString(),
      "deliveryAddress": widget.selectAddress["addressId"].toString(),
      "pickupTime": formatted,
      "deliveryTime": formatted,
      "items": widget.cartItems,
      "payment": {
        "paymentMethod": "RazorPay",
        "amount": widget.totalPayPrice.toString()
      },
      "billingBreakup": {
        "subtotal": widget.totalPayPrice.toString(),
        "tax": "0.00",
        "deliveryFee": "0.00",
        "discount": "0.00",
        "serviceFee": "0.00",
        "totalAmount": widget.totalPayPrice.toString()
      }
    };

    final res = await ApiService.postRequest("order", option);

    setState(() {
      _orderDetails = res;
    });

    try {
      final username = 'rzp_test_OMKGVUbxYh76JB';
      final password = '6ozpi9TZ7kDl6cyWtk5oPZUE';

      final credentials = base64Encode(utf8.encode('$username:$password'));

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $credentials',
      };

      final body = jsonEncode({
        "amount": widget.totalPayPrice * 100,
        "currency": "INR",
        "receipt": "paymentId_${res["payment"]["paymentId"]}",
      });

      final response = await http.post(
        Uri.parse('https://api.razorpay.com/v1/orders'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("Order created: $data");
        _razorpayOrderDetails = data;
        setState(() {});

        //   init payment
        var options = {
          'key': username,
          'amount': data["amount"], //in paise.
          'name': 'BI Pvt Ltd Demo Payment',
          'order_id': data["id"], // Generate order_id using Orders API
          'description': data["receipt"],
          'timeout': 300, // in seconds
          'prefill': {
            'contact': widget.selectAddress["phoneNumber"],
            'email': widget.email
          }
        };

        _razorpay.open(options);
      } else {
        print("Error: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print('POST Request Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Payment Method",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Bill Total Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // "Bill Total"
                  Text(
                    "Bill Total",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      // "₹585"
                      Text(
                        "₹${widget.totalPayPrice}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 4.w),

                      // Arrow
                      Icon(
                        Icons.chevron_right,
                        color: Colors.black87,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 2) Cards
            _buildPaymentSection(
              title: "Cards",
              subtitle: "Add credit or debit cards",
              trailingText: "Add",
              onTap: () {
                // Implement card-adding logic

                // var options = {
                //   'key': 'rzp_test_9oAfGGhC796rqO', // your key goes here
                //   'amount': 10 * 100,
                //   'name': 'SSHegde.Visuals',
                //   'description': 'Coffe bills',
                //   'timeout': 60,
                //   // add users contact & email
                //   'prefill': {
                //     'contact': '8888888888',
                //     'email': 'test@razorpay.com'
                //   }
                // };

                var options = {
                  "key": "rzp_test_NtION5KUtDEYJB",
                  "order_id": "sub_QLK87wOk7JWmV7",
                  // "customer_id": "cust_BtQNqzmBlXXXX",
                  "prefill": {
                    "contact": "+919000090000",
                    "email": "gaurav.kumar@example.com"
                  },
                  "image":
                      "https://spaceplace.nasa.gov/templates/featured/sun/sunburn300.png",
                  // "amount": 1000000,
                  // Amount should match the order amount
                  "currency": "INR",
                  // "recurring": 1
                  // This key value pair is mandatory for Intent Recurring Payment.
                };
                _razorpay.open(options);
              },
            ),
            SizedBox(height: 12.h),

            // 3) UPI
            _buildPaymentSection(
              title: "UPI",
              subtitle: "Add new UPI ID",
              trailingText: "Add",
              onTap: () {
                // Implement UPI-adding logic
              },
            ),
            SizedBox(height: 12.h),

            // 4) Wallets
            Text(
              "Wallets",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),

            // Example wallets
            _buildWalletRow(
              iconAsset: Icons.payment, // or your custom icon for Amazon Pay
              walletName: "Amazon pay",
              onTap: () {
                // Link Amazon pay
              },
            ),
            SizedBox(height: 8.h),

            _buildWalletRow(
              iconAsset: Icons.payment, // or your custom icon for Paytm
              walletName: "Paytm",
              onTap: () {
                // Link Paytm
              },
            ),

            // Add more wallets if needed...
          ],
        ),
      ),
    );
  }

  /// A helper to build a payment section like "Cards" or "UPI"
  Widget _buildPaymentSection({
    required String title,
    required String subtitle,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Right "Add" link
          GestureDetector(
            onTap: onTap,
            child: Text(
              trailingText,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A helper to build each wallet row
  Widget _buildWalletRow({
    required IconData iconAsset,
    required String walletName,
    required VoidCallback onTap,
  }) {
    return Container(
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
      child: Row(
        children: [
          // Left icon
          Icon(
            iconAsset,
            size: 20.sp,
            color: Colors.green.shade900,
          ),
          SizedBox(width: 8.w),

          // Wallet name
          Expanded(
            child: Text(
              walletName,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),

          // Right "Link"
          GestureDetector(
            onTap: onTap,
            child: Text(
              "Link",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
