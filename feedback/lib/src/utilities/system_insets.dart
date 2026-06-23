// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// System UI insets for the feedback overlay.
///
/// [SafeArea] reads [MediaQueryData.padding], which is often zero on the bottom
/// in edge-to-edge apps even when the 3-button navigation bar is visible.
/// [MediaQueryData.viewPadding] always includes those physical insets.
extension FeedbackSystemInsets on MediaQueryData {
  double get feedbackTopInset => viewPadding.top;

  double get feedbackBottomInset => viewPadding.bottom;

  double get feedbackAvailableHeight =>
      size.height - feedbackTopInset - feedbackBottomInset - viewInsets.bottom;
}
