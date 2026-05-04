import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constans/Colors.dart';

class CustomInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType inputType;
  final bool obscureText;
  final bool isDisabled;

  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;

  const CustomInput({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.inputType = TextInputType.text,
    this.obscureText = false,
    this.isDisabled = false,
    this.errorText,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.inputFormatters,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: textTheme.titleSmall?.copyWith(color: AppColors.base500),
          ),
          const SizedBox(height: 8),
        ],

        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: inputType,
          obscureText: obscureText,
          enabled: !isDisabled,
          onChanged: onChanged,
          validator: validator,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autovalidateMode: autovalidateMode,
          style: textTheme.titleMedium?.copyWith(
            color: isDisabled ? AppColors.base400 : AppColors.base900,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,

            filled: true,
            fillColor: isDisabled ? AppColors.base100 : AppColors.base200,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.base300, width: 1),
            ),

            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.base400,
              fontStyle: FontStyle.normal,
            ),
            errorStyle: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
