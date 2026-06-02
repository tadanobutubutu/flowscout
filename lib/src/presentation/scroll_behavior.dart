import 'package:flutter/material.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  const MyCustomScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Use ClampingScrollPhysics for Android, BouncingScrollPhysics for iOS, with smooth acceleration
    return const ClampingScrollPhysics(parent: const BouncingScrollPhysics());
  }
}
