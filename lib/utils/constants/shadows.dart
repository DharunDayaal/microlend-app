import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // Dark: hard 4px offset, zero blur (bottom sheets, sticky collect bar)
  static const List<BoxShadow> hardDark = [
    BoxShadow(
      color: Color(0x99000000),
      offset: Offset(0, 4),
      blurRadius: 0,
    ),
  ];

  // Light: card
  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color(0x0D0F172A),
      offset: Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  // Light: raised (bottom sheets, modals)
  static const List<BoxShadow> raisedLight = [
    BoxShadow(
      color: Color(0x140F172A),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];
}