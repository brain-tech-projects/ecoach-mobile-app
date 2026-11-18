import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';

/// Stripe Checkout inside the app. Closes itself with the Stripe session id
/// when Stripe redirects to [successUrl], or with null on [cancelUrl] / back.
class StripeCheckoutPage extends StatefulWidget {
  const StripeCheckoutPage({super.key, required this.url, required this.successUrl, required this.cancelUrl, this.fallbackSessionId});

  final String url;
  final String successUrl;
  final String cancelUrl;
  final String? fallbackSessionId;

  @override
  State<StripeCheckoutPage> createState() => _StripeCheckoutPageState();
}

class _StripeCheckoutPageState extends State<StripeCheckoutPage> {
  late final WebViewController _web;
  bool _loading = true;
  bool _failed = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigate,
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (e) {
            // Only a failing main page matters (not images / trackers).
            if (e.isForMainFrame ?? true) {
              if (mounted) setState(() { _failed = true; _loading = false; });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  NavigationDecision _onNavigate(NavigationRequest request) {
    final url = request.url;
    if (url.startsWith(widget.successUrl)) {
      final id = Uri.tryParse(url)?.queryParameters['session_id'];
      _close((id == null || id.isEmpty) ? widget.fallbackSessionId : id);
      return NavigationDecision.prevent;
    }
    if (url.startsWith(widget.cancelUrl)) {
      _close(null);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  void _close(String? sessionId) {
    if (_closed) return;
    _closed = true;
    Get.back<String>(result: sessionId);
  }

  void _retry() {
    setState(() { _failed = false; _loading = true; });
    _web.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    return SubPageScaffold(
      title: 'Subscription',
      showNav: false,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: WebViewWidget(controller: _web)),
          if (_loading && !_failed) const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          if (_failed)
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.background,
                child: Padding(
                  padding: EdgeInsets.all(28 * s),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Could not open the payment page. Please check your connection.', textAlign: TextAlign.center, style: AppTextStyles.sectionTitle.scaled(s)),
                      SizedBox(height: 22 * s),
                      AppPrimaryButton(label: 'Try again', onPressed: _retry, scale: s),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
