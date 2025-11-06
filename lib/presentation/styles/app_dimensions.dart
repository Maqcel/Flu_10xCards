import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App-wide dimensions using flutter_screenutil for responsive design.
/// All dimensions should be accessed through this class to maintain consistency
/// Never use magic numbers directly in UI code.
abstract class AppDimensions {
  // Mobile design dimensions reference: 375 x 812 (iPhone X)
  static const Size mobileMockSize = Size(375, 812);

  // Heights
  static double get h4 => 4.h;
  static double get h8 => 8.h;
  static double get h12 => 12.h;
  static double get h16 => 16.h;
  static double get h20 => 20.h;
  static double get h24 => 24.h;
  static double get h32 => 32.h;
  static double get h40 => 40.h;
  static double get h48 => 48.h;
  static double get h56 => 56.h;
  static double get h64 => 64.h;
  static double get h72 => 72.h;
  static double get h80 => 80.h;
  static double get h96 => 96.h;
  static double get h120 => 120.h;
  static double get h160 => 160.h;
  static double get h200 => 200.h;

  // Widths
  static double get w4 => 4.w;
  static double get w8 => 8.w;
  static double get w12 => 12.w;
  static double get w16 => 16.w;
  static double get w20 => 20.w;
  static double get w24 => 24.w;
  static double get w32 => 32.w;
  static double get w40 => 40.w;
  static double get w48 => 48.w;
  static double get w56 => 56.w;
  static double get w64 => 64.w;
  static double get w72 => 72.w;
  static double get w80 => 80.w;
  static double get w96 => 96.w;
  static double get w120 => 120.w;
  static double get w160 => 160.w;
  static double get w200 => 200.w;

  // Padding
  static double get padding4 => 4.w;
  static double get padding8 => 8.w;
  static double get padding12 => 12.w;
  static double get padding16 => 16.w;
  static double get padding20 => 20.w;
  static double get padding24 => 24.w;
  static double get padding32 => 32.w;

  // Margin
  static double get margin4 => 4.w;
  static double get margin8 => 8.w;
  static double get margin12 => 12.w;
  static double get margin16 => 16.w;
  static double get margin20 => 20.w;
  static double get margin24 => 24.w;
  static double get margin32 => 32.w;

  // Spacing (for Column/Row spacing parameter)
  static double get spacing4 => 4.w;
  static double get spacing8 => 8.w;
  static double get spacing12 => 12.w;
  static double get spacing16 => 16.w;
  static double get spacing20 => 20.w;
  static double get spacing24 => 24.w;
  static double get spacing32 => 32.w;

  // Border Radius
  static double get radius4 => 4.r;
  static double get radius8 => 8.r;
  static double get radius12 => 12.r;
  static double get radius16 => 16.r;
  static double get radius20 => 20.r;
  static double get radius24 => 24.r;
  static double get radius32 => 32.r;

  // Font Sizes
  static double get fontSize10 => 10.sp;
  static double get fontSize12 => 12.sp;
  static double get fontSize14 => 14.sp;
  static double get fontSize16 => 16.sp;
  static double get fontSize18 => 18.sp;
  static double get fontSize20 => 20.sp;
  static double get fontSize24 => 24.sp;
  static double get fontSize28 => 28.sp;
  static double get fontSize32 => 32.sp;

  // Icon Sizes
  static double get iconSize16 => 16.w;
  static double get iconSize20 => 20.w;
  static double get iconSize24 => 24.w;
  static double get iconSize32 => 32.w;
  static double get iconSize40 => 40.w;
  static double get iconSize48 => 48.w;
}
