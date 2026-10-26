import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';

/// Top-of-screen toasts. They stack (newest on top), auto-dismiss after 4 s
/// and can be tapped away. Works from anywhere (no BuildContext needed).
///
///   AppToast.success('Skill video marked as completed');
///   AppToast.reward(title: 'Skill Video Completed', message: '...');
abstract final class AppToast {
  static final ValueNotifier<List<_ToastData>> _items =
      ValueNotifier<List<_ToastData>>(const <_ToastData>[]);
  static OverlayEntry? _entry;
  static int _seq = 0;

  static void success(String message) =>
      _add(_ToastData(id: ++_seq, message: message));

  /// Neutral hint (e.g. "Complete the previous video first").
  static void info(String message) => _add(
    _ToastData(id: ++_seq, message: message, icon: Icons.lock_outline),
  );

  static void reward({required String title, required String message}) =>
      _add(_ToastData(id: ++_seq, title: title, message: message));

  static void _add(_ToastData data) {
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null) return;

    _items.value = <_ToastData>[data, ..._items.value];
    if (_entry == null) {
      _entry = OverlayEntry(builder: (_) => const _ToastHost());
      overlay.insert(_entry!);
    }
    Timer(const Duration(seconds: 4), () => _remove(data.id));
  }

  static void _remove(int id) {
    _items.value = _items.value.where((t) => t.id != id).toList();
    if (_items.value.isEmpty) {
      _entry?.remove();
      _entry = null;
    }
  }
}

class _ToastData {
  const _ToastData({
    required this.id,
    required this.message,
    this.title,
    this.icon,
  });

  final int id;
  final IconData? icon;
  final String? title;
  final String message;
}

class _ToastHost extends StatelessWidget {
  const _ToastHost();

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16 * s, r.safeTop + 16 * s, 16 * s, 0),
          child: ValueListenableBuilder<List<_ToastData>>(
            valueListenable: AppToast._items,
            builder: (context, items, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (final item in items)
                  Padding(
                    key: ValueKey<int>(item.id),
                    padding: EdgeInsets.only(bottom: 7.7 * s),
                    child: _ToastCard(
                      data: item,
                      scale: s,
                      onTap: () => AppToast._remove(item.id),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.data,
    required this.scale,
    required this.onTap,
  });

  final _ToastData data;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final title = data.title;

    final content = title == null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                data.icon ?? Icons.check_circle,
                size: 20 * s,
                color: data.icon == null
                    ? AppColors.selectGreen
                    : AppColors.unselectedBorder,
              ),
              SizedBox(width: 10 * s),
              Flexible(
                child: Text(data.message, style: AppTextStyles.toastBody.scaled(s)),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTextStyles.toastTitle.scaled(s)),
              Text(data.message, style: AppTextStyles.toastBody.scaled(s)),
            ],
          );

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, -12 * (1 - t)), child: child),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350 * s),
          child: Container(
            padding: title == null
                ? EdgeInsets.symmetric(horizontal: 10 * s, vertical: 11 * s)
                : EdgeInsets.fromLTRB(20 * s, 13 * s, 20 * s, 13 * s),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12 * s),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
