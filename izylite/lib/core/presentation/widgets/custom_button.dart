import 'package:flutter/material.dart';
import '../../constans/Colors.dart';

class CustomButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final double radius;

  final Color borderColor;
  final Color backgroundColor;
  final Color disabledColor;
  final Gradient? gradient;

  final bool isDisabled;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 50.0,
    this.padding,
    this.radius = 12.0,
    this.isDisabled = false,
    this.isLoading = false,
    this.borderColor = Colors.transparent,
    this.backgroundColor = AppColors.primary,
    this.disabledColor = AppColors.base300,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool actuallyDisabled = isDisabled || isLoading || onPressed == null;
    final textTheme = Theme.of(context).textTheme;

    final BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: actuallyDisabled ? null : gradient,
      color: actuallyDisabled
          ? disabledColor
          : (gradient == null ? backgroundColor : null),
    );

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: decoration,
        child: ElevatedButton(
          onPressed: actuallyDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(
                color: actuallyDisabled ? Colors.transparent : borderColor,
              ),
            ),
          ),
          child: isLoading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : DefaultTextStyle(
            style: textTheme.titleSmall!.copyWith(
              color: actuallyDisabled ? AppColors.base500 : Colors.white,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}