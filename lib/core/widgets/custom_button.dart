import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool enabled;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColor ?? Colors.white,
                    ),
                  ),
                )
                : Text(
                  text,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
      ),
    );
  }
}
