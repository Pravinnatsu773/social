// custom_text_widget.dart
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final FontWeight fontWeight;
  final double fontSize;
  final TextDirection? textDirection;
  final Color textColor;

  const CustomText({
    Key? key,
    required this.text,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.textDirection,
    this.textColor = const Color(0xff08051B),
    this.fontWeight = FontWeight.normal,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: textColor,
          // fontFamily: 'Poppins',
          fontWeight: fontWeight,
          fontSize: fontSize),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      textDirection: textDirection,
    );
  }
}
