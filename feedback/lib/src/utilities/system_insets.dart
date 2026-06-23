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

  /// Nav-bar inset for layout when the keyboard is closed. When [viewInsets.bottom]
  /// is non-zero the keyboard already occupies the bottom edge.
  double get feedbackLayoutBottomInset =>
      viewInsets.bottom > 0 ? 0 : feedbackBottomInset;

  double get feedbackAvailableHeight =>
      size.height - feedbackTopInset - feedbackBottomInset - viewInsets.bottom;
}
