import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_background.dart';

/// Shared frame for the auth screens: gradient background, back arrow
/// (top-left) and a scrollable, width-limited, 22 pt-padded content area.
///
/// Content starts at the design's y = 20 pt (shifted below the status bar on
/// notched phones), so design offsets can be used as `designY - 20`.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    required this.onBack,
    this.footer,
  });

  final Widget child;
  final VoidCallback onBack;

  /// Optional widget pinned to the bottom (e.g. "Resend Code").
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final top = math.max(r.safeTop, r.s(20));
    final bottom = math.max(r.safeBottom, r.s(24));

    return Scaffold(
      body: AppBackground(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        top: top,
                        bottom: footer == null ? bottom : r.s(16),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: r.contentMaxWidth,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.s(22),
                            ),
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (footer != null)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: math.max(r.safeBottom, r.s(18.5)),
                      ),
                      child: footer,
                    ),
                ],
              ),
            ),
            Positioned(
              left: r.s(12),
              top: top,
              child: IconButton(
                onPressed: onBack,
                tooltip: 'Back',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                iconSize: r.s(25),
                color: AppColors.white,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
