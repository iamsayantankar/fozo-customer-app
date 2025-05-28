import 'package:fozo_customer_app/utils/constant/dimensions.dart';
import 'package:fozo_customer_app/utils/theme/theme_constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class GeneralMultiSelectCheckbox extends StatefulWidget {

  GeneralMultiSelectCheckbox({
    Key? key,
    required this.title,
    required this.height,
    required this.width,
    required this.boxWidth,
    required this.isSelected,
    required this.onTap,
    required this.borderColor,
    required this.fillColor,
    required this.checkColor,
    required this.bgColor,
  }) : super(key: key);

  Text title;
   double height;
  double width;
  double boxWidth;
   Color borderColor;
  Color fillColor;
  Color checkColor;
  Color bgColor;

  bool isSelected;
  VoidCallback onTap;

  @override
  // ignore: library_private_types_in_public_api
  _GeneralMultiSelectCheckboxState createState() =>
      _GeneralMultiSelectCheckboxState();
}

class _GeneralMultiSelectCheckboxState
    extends State<GeneralMultiSelectCheckbox> {
  // bool _isChecked = false;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.borderColor),
        ),
        width: widget.width,
        height: widget.height,
        child:
      Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                fillColor: MaterialStateProperty.all(widget.fillColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                ),
                checkColor: widget.checkColor,
                value: widget.isSelected,
                onChanged: null,
              ),
              SizedBox(
                  width: widget.boxWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: widget.title,
                  )
              ),
            ],
          ),

      ),
    );
  }
}
