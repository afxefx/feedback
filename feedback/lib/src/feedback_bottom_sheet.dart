// ignore_for_file: public_member_api_docs

import 'package:feedback/src/better_feedback.dart';
import 'package:feedback/src/theme/feedback_theme.dart';
import 'package:feedback/src/utilities/back_button_interceptor.dart';
import 'package:feedback/src/utilities/system_insets.dart';
import 'package:flutter/material.dart';

/// Shows the text input in which the user can describe his feedback.
class FeedbackBottomSheet extends StatelessWidget {
  const FeedbackBottomSheet({
    super.key,
    required this.feedbackBuilder,
    required this.onSubmit,
    required this.sheetProgress,
  });

  final FeedbackBuilder feedbackBuilder;
  final OnSubmit onSubmit;
  final ValueNotifier<double> sheetProgress;

  @override
  Widget build(BuildContext context) {
    if (FeedbackTheme.of(context).sheetIsDraggable) {
      return DraggableScrollableActuator(
        child: _DraggableFeedbackSheet(
          feedbackBuilder: feedbackBuilder,
          onSubmit: onSubmit,
          sheetProgress: sheetProgress,
        ),
      );
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: MediaQuery.of(context).size.height *
            FeedbackTheme.of(context).feedbackSheetHeight,
        child: Material(
          color: FeedbackTheme.of(context).feedbackSheetColor,
          // Pass a null scroll controller because the sheet is not drag
          // enabled.
          child: Navigator(
            onGenerateRoute: (_) {
              return MaterialPageRoute<void>(
                builder: (_) => feedbackBuilder(
                  context,
                  onSubmit,
                  null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DraggableFeedbackSheet extends StatefulWidget {
  const _DraggableFeedbackSheet({
    required this.feedbackBuilder,
    required this.onSubmit,
    required this.sheetProgress,
  });

  final FeedbackBuilder feedbackBuilder;
  final OnSubmit onSubmit;
  final ValueNotifier<double> sheetProgress;

  @override
  State<_DraggableFeedbackSheet> createState() =>
      _DraggableFeedbackSheetState();
}

class _DraggableFeedbackSheetState extends State<_DraggableFeedbackSheet> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_onBackButton, priority: 0);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_onBackButton);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FeedbackThemeData feedbackTheme = FeedbackTheme.of(context);
    final MediaQueryData query = MediaQuery.of(context);
    // Recalculate the collapsed height to account for the top inset and keyboard.
    // Bottom inset is handled by [_FeedbackLayoutDelegate].
    final double availableHeight = query.size.height -
        query.feedbackTopInset -
        query.viewInsets.bottom;
    final double collapsedHeight = availableHeight <= 0
        ? feedbackTheme.feedbackSheetHeight
        : feedbackTheme.feedbackSheetHeight *
            query.size.height /
            availableHeight;
    final safeAreaTop = query.feedbackTopInset;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: safeAreaTop),
          child: DraggableScrollableSheet(
            controller: BetterFeedback.of(context).sheetController,
            snap: true,
            minChildSize: collapsedHeight,
            initialChildSize: collapsedHeight,
            builder: (context, scrollController) {
              return ValueListenableBuilder<void>(
                valueListenable: widget.sheetProgress,
                builder: (context, _, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                          20 * (1 - widget.sheetProgress.value)),
                    ),
                    child: child,
                  );
                },
                child: Material(
                  color: FeedbackTheme.of(context).feedbackSheetColor,
                  child: DefaultTextEditingShortcuts(
                    child: Navigator(
                      onGenerateRoute: (_) {
                        return MaterialPageRoute<void>(
                          builder: (_) => widget.feedbackBuilder(
                            context,
                            widget.onSubmit,
                            scrollController,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ValueListenableBuilder<void>(
          valueListenable: widget.sheetProgress,
          child: Container(
            height: safeAreaTop,
            color: FeedbackTheme.of(context).feedbackSheetColor,
          ),
          builder: (context, _, child) {
            return Opacity(
              opacity: widget.sheetProgress.value,
              child: child,
            );
          },
        ),
      ],
    );
  }

  bool _onBackButton() {
    if (widget.sheetProgress.value != 0) {
      // TODO(caseycrogers): replace `reset` with `animateTo` when
      //   `DraggableScrollableController` reaches production
      if (DraggableScrollableActuator.reset(context)) {
        widget.sheetProgress.value = 0;
        return true;
      }
    }
    return false;
  }
}
