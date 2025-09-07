import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.gradient
  });


  final Color success;
  final Color warning;
  final Color info;
  final Gradient gradient;

  @override
  ThemeExtension<AppColors> copyWith(
      { Color? success, Color? warning, Color? info, Gradient? gradient }) =>
      AppColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        info: info ?? this.warning,
        gradient: gradient ?? this.gradient,
      );

  @override
  ThemeExtension<AppColors> lerp(covariant ThemeExtension<AppColors>? other,
      double t) => this;

}