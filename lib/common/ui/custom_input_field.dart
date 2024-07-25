import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool showBorder;
  final bool allowSpace;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefix;

  final Widget? suffix;
  final double borderRadius;
  final Color? borderColor;
  final TextStyle? prefixStyle;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final EdgeInsets? contentPadding;
  final Color fillColor;
  const CustomInputField(
      {Key? key,
      required this.hintText,
      this.controller,
      this.keyboardType,
      this.obscureText = false,
      this.enabled = true,
      this.showBorder = true,
      this.maxLines = 1,
      this.maxLength,
      this.onChanged,
      this.allowSpace = true,
      this.prefix,
      this.prefixStyle,
      this.focusNode,
      this.suffix,
      this.fillColor = Colors.white,
      this.borderRadius = 8.0,
      this.borderColor,
      this.contentPadding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: Key(hintText),
      enabled: enabled,

      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      // showCursor: false,
      onChanged: onChanged,

      inputFormatters: allowSpace
          ? []
          : [
              FilteringTextInputFormatter.deny(RegExp(r'\s')),
            ],

      cursorColor: const Color(0xff5348EE),
      maxLines: maxLines,

      maxLength: maxLength,
      decoration: InputDecoration(
        suffixIcon: suffix,
        prefixIcon: prefix,
        // prefixStyle: prefixStyle,
        prefixIconConstraints: const BoxConstraints(maxWidth: 28),
        counter: const SizedBox(),
        hintStyle: const TextStyle(
            color: Color(0xff8F8D9B), fontWeight: FontWeight.w400),
        hintText: hintText,
        filled: true,
        fillColor: fillColor,

        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),

        border: showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ??
                      Colors.grey.shade300, // Light grey border color
                  width: 1.5,
                ),
              )
            : InputBorder.none,
        enabledBorder: showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ??
                      Colors.grey.shade300, // Light grey border color
                  width: 1.5,
                ),
              )
            : InputBorder.none,
        disabledBorder: showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ??
                      Colors.grey.shade300, // Light grey border color
                  width: 1.5,
                ),
              )
            : InputBorder.none,
        focusedBorder: showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: borderColor ??
                      Colors.grey.shade300, // Slightly darker grey for focus
                  width: 1.5,
                ),
              )
            : InputBorder.none,
      ),
    );
  }
}
