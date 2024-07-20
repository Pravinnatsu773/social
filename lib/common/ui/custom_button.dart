// custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final Color? color;
  final Color textColor;
  final double borderRadius;
  final double textSize;
  final BoxBorder? border;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 40,
    this.textSize = 16.0,
    this.color,
    this.textColor = Colors.white,
    this.borderRadius = 50.0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: color ?? const Color(0xff5348EE),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: textSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
