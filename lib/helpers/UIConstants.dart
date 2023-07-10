import 'package:flutter/material.dart';

class UIConstants {
  static const double borderRadius12 = 12.0;
  static const double borderRadius16 = 16.0;

  static const double padding8 = 8.0;
  static const double padding12 = 12.0;
  static const double padding16 = 16.0;

  static BoxDecoration boxShadowDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(borderRadius12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.shade500,
        spreadRadius: 1,
        blurRadius: 0.5,
        blurStyle: BlurStyle.outer
      )
    ]
  );
}