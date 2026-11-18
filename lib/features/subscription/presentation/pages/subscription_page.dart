import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/subscription/domain/entities/subscription_plan.dart';
import 'package:ecoach_pro/features/subscription/presentation/controllers/subscription_controller.dart';

const Color _info = Color(0xFF2DB9E8);
const Color _danger = Color(0xFFE5313F);

/// Plans screen. Opened from the menu, and automatically when the API answers
/// "Subscription required".
class SubscriptionPage extends GetView<SubscriptionController> {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;

    return SubPageScaffold(
      title: 'Subscription',
      showNav: false,
      body: Obx(() {
        if (controller.verifying.value) return _Verifying(scale: s);
        final done = controller.success.value;
        if (done != null) return _PaymentSuccess(result: done, scale: s, onHome: controller.goHome);
        if (controller.loading.value && controller.plans.isEmpty) return const AppLoader();
        final error = controller.errorMessage.value;
        if (error != null && controller.plans.isEmpty) {
          return _LoadError(message: error, scale: s, onRetry: controller.load);
        }
        return _Plans(controller: controller, scale: s);
      }),
    );
  }
}

class _Plans extends StatelessWidget {
  const _Plans({required this.controller, required this.scale});
  final SubscriptionController controller;
  final double scale;

  @override
  Widget build(BuildContext context) => Obx(() => _body(context));

  Widget _body(BuildContext context) {
    final r = Responsive.of(context);
    final s = scale;
    final white = AppTextStyles.sectionTitle.scaled(s);
    final plans = controller.plans.toList();
    final my = controller.myPlan.value;
    final eligible = controller.trialEligible;

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      onRefresh: () => controller.load(silent: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(r.gutter + 24 * s, 24 * s, r.gutter + 24 * s, 24 * s + r.safeBottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: AppLogoHorizontal(scale: s)),
            SizedBox(height: 18 * s),
            Text('Unlock the full eCoach experience', textAlign: TextAlign.center, style: white),
            SizedBox(height: 4 * s),
            if (eligible && !(my?.isSubscribed ?? false)) ...<Widget>[
              Text('TAKE A ${controller.trialDays} DAY FREE TRIAL', textAlign: TextAlign.center, style: white.copyWith(color: AppColors.selectGreen)),
              SizedBox(height: 8 * s),
            ],
            Text('Cancel Anytime', textAlign: TextAlign.center, style: AppTextStyles.programDesc.scaled(s)),
            SizedBox(height: 22 * s),
            for (final plan in plans) ...<Widget>[
              _PlanCard(plan: plan, controller: controller, scale: s),
              SizedBox(height: 26 * s),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.lock_outline, size: 18 * s, color: AppColors.hint),
                SizedBox(width: 8 * s),
                Text('Secure payments powered by Stripe', style: AppTextStyles.programDesc.scaled(s)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.controller, required this.scale});

  final SubscriptionPlan plan;
  final SubscriptionController controller;
  final double scale;

  @override
  Widget build(BuildContext context) => Obx(() => _body(context));

  Widget _body(BuildContext context) {
    final s = scale;
    final body = AppTextStyles.programDesc.scaled(s);
    final my = controller.myPlan.value;
    final subscribed = my?.isSubscribed ?? false;
    final current = my != null && my.isCurrent(plan);
    final features = controller.featuresOf(plan);
    final radius = BorderRadius.circular(18 * s);
    final note = (!subscribed && (my?.subtitleText ?? '').isNotEmpty) ? '${plan.billingNote}\n${my!.subtitleText}' : plan.billingNote;

    final content = Padding(
      padding: EdgeInsets.fromLTRB(22 * s, 26 * s, 22 * s, 22 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(child: Text(plan.title, style: AppTextStyles.programTitle.scaled(s))),
          SizedBox(height: 10 * s),
          Center(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(text: plan.weeklyPrice, style: AppTextStyles.sectionTitle.scaled(s).copyWith(color: AppColors.selectGreen, fontSize: 22 * s)),
                  TextSpan(text: ' /week', style: body),
                ],
              ),
            ),
          ),
          SizedBox(height: 12 * s),
          Center(child: Text(note, textAlign: TextAlign.center, style: body)),
          SizedBox(height: 18 * s),
          for (final feature in features)
            Padding(
              padding: EdgeInsets.only(bottom: 10 * s),
              child: Row(
                children: <Widget>[
                  Icon(Icons.check, size: 18 * s, color: AppColors.selectGreen),
                  SizedBox(width: 10 * s),
                  Expanded(child: Text(feature, style: body.copyWith(color: AppColors.white))),
                ],
              ),
            ),
          if (!subscribed) ...<Widget>[
            SizedBox(height: 14 * s),
            AppPrimaryButton(
              label: controller.buttonLabel(),
              onPressed: () => controller.subscribe(plan),
              loading: controller.busyPlan.value == plan.id,
              scale: s,
            ),
          ],
          if (current) ...<Widget>[SizedBox(height: 14 * s), _RenewalInfo(controller: controller, my: my, scale: s)],
        ],
      ),
    );

    return Semantics(
      button: !subscribed,
      label: '${plan.title} plan, ${plan.weeklyPrice} per week${current ? ', current plan' : ''}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: subscribed && !current ? () => controller.subscribe(plan) : null,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 14 * s),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: radius,
                color: current ? const Color(0xFF122D33) : null,
                border: Border.all(color: AppColors.selectGreen.withValues(alpha: current ? 1 : 0.7), width: current ? 1.5 : 1),
                boxShadow: current ? <BoxShadow>[BoxShadow(color: AppColors.selectGreen.withValues(alpha: 0.35), blurRadius: 22 * s)] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  content,
                  if (current) _CurrentBar(label: _barLabel(my!), scale: s),
                ],
              ),
            ),
            if (plan.mostPopular)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 6 * s),
                decoration: BoxDecoration(color: AppColors.selectGreen, borderRadius: BorderRadius.circular(14 * s)),
                child: Text('MOST POPULAR', style: AppTextStyles.heroButton.scaled(s)),
              ),
          ],
        ),
      ),
    );
  }

  String _barLabel(MyPlan my) {
    if (my.renewalOff) return my.accessUntil.isEmpty ? 'Current Plan' : 'Ends on ${my.accessUntil}';
    return my.buttonText.isEmpty ? 'Current Plan' : my.buttonText;
  }
}

/// Under the features of the current plan: renewal info + cancel link / box.
class _RenewalInfo extends StatelessWidget {
  const _RenewalInfo({required this.controller, required this.my, required this.scale});
  final SubscriptionController controller;
  final MyPlan? my;
  final double scale;

  @override
  Widget build(BuildContext context) => Obx(() => _body(context));

  Widget _body(BuildContext context) {
    final s = scale;
    final confirming = controller.confirmingCancel.value; // read first: Obx needs an observable
    final busy = controller.cancelling.value;
    final plan = my;
    if (plan == null) return const SizedBox.shrink();
    final body = AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 19 * s);

    if (plan.renewalOff) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10 * s),
        child: Text(
          plan.accessUntil.isEmpty ? 'Auto-renewal is off.' : 'Auto-renewal is off. Access until ${plan.accessUntil}.',
          textAlign: TextAlign.center,
          style: body.copyWith(color: _info, fontWeight: FontWeight.w500),
        ),
      );
    }

    if (confirming) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 18 * s),
        padding: EdgeInsets.fromLTRB(14 * s, 16 * s, 14 * s, 16 * s),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12 * s), border: Border.all(color: _danger)),
        child: Column(
          children: <Widget>[
            Text(
              plan.accessUntil.isEmpty ? 'Cancel auto-renewal?' : "Cancel auto-renewal? You'll keep access until ${plan.accessUntil}.",
              textAlign: TextAlign.center,
              style: body.copyWith(color: AppColors.white),
            ),
            SizedBox(height: 12 * s),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12 * s,
              runSpacing: 8 * s,
              children: <Widget>[
                _SmallButton(label: busy ? 'Cancelling...' : 'Yes, cancel', fill: _danger, onTap: busy ? null : controller.confirmCancel, scale: s),
                _SmallButton(label: 'Keep plan', outline: true, onTap: busy ? null : controller.keepPlan, scale: s),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        if (plan.nextBilling.isNotEmpty) Text('Auto-renews on ${plan.nextBilling}', textAlign: TextAlign.center, style: body),
        SizedBox(height: 8 * s),
        Semantics(
          button: true,
          label: 'Cancel auto-renewal',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.askCancel,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6 * s, horizontal: 12 * s),
              child: Text('Cancel auto-renewal', style: body.copyWith(color: _danger, decoration: TextDecoration.underline, decorationColor: _danger)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.onTap, required this.scale, this.fill, this.outline = false});
  final String label;
  final VoidCallback? onTap;
  final double scale;
  final Color? fill;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Opacity(
      opacity: onTap == null ? 0.6 : 1,
      child: Material(
        color: fill ?? Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6 * s), side: outline ? const BorderSide(color: AppColors.white) : BorderSide.none),
        child: InkWell(
          borderRadius: BorderRadius.circular(6 * s),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 10 * s),
            child: Text(label, style: AppTextStyles.programTitle.scaled(s).copyWith(fontSize: 19 * s, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}

/// Green bar at the bottom of the current plan ("Current Plan ->").
class _CurrentBar extends StatelessWidget {
  const _CurrentBar({required this.label, required this.scale});
  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Container(
      height: 56 * s,
      color: AppColors.accent,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: AppTextStyles.buttonLabel.scaled(s).copyWith(color: AppColors.black, fontWeight: FontWeight.w600)),
          SizedBox(width: 12 * s),
          Icon(Icons.arrow_forward, size: 24 * s, color: AppColors.black),
        ],
      ),
    );
  }
}

class _Verifying extends StatelessWidget {
  const _Verifying({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const CircularProgressIndicator(color: AppColors.accent),
        SizedBox(height: 18 * scale),
        Text('Confirming your payment...', style: AppTextStyles.programDesc.scaled(scale)),
      ],
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.scale, required this.onRetry});
  final String message;
  final double scale;
  final Future<void> Function({bool silent}) onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 32 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center, style: AppTextStyles.sectionTitle.scaled(scale)),
          SizedBox(height: 22 * scale),
          AppPrimaryButton(label: 'Try again', onPressed: () => onRetry(), scale: scale),
        ],
      ),
    ),
  );
}

/// "Payment Successful" card shown after Stripe confirms the payment.
class _PaymentSuccess extends StatelessWidget {
  const _PaymentSuccess({required this.result, required this.scale, required this.onHome});
  final PaymentResult result;
  final double scale;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final r = Responsive.of(context);
    final grey = AppTextStyles.programDesc.scaled(s).copyWith(fontSize: 21 * s, color: AppColors.descGrey, height: 1.5);
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: r.gutter + 8 * s),
        padding: EdgeInsets.fromLTRB(24 * s, 36 * s, 24 * s, 36 * s),
        decoration: BoxDecoration(color: const Color(0xFF103A37), borderRadius: BorderRadius.circular(32 * s), border: Border.all(color: AppColors.selectGreen, width: 1.5)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 90 * s,
              height: 90 * s,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFF1A5445), shape: BoxShape.circle),
              child: Container(
                width: 44 * s,
                height: 44 * s,
                decoration: const BoxDecoration(color: Color(0xFF3DDC97), shape: BoxShape.circle),
                child: Icon(Icons.check, size: 26 * s, color: const Color(0xFF0E3B33)),
              ),
            ),
            SizedBox(height: 26 * s),
            Text('Payment Successful', textAlign: TextAlign.center, style: AppTextStyles.sectionTitle.scaled(s).copyWith(fontSize: 31 * s, fontWeight: FontWeight.w700)),
            SizedBox(height: 18 * s),
            Text.rich(
              TextSpan(
                style: grey,
                children: <InlineSpan>[
                  const TextSpan(text: 'Thank you for subscribing to our '),
                  if (result.planName.isNotEmpty) TextSpan(text: result.planName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: result.planName.isEmpty ? 'plan.' : ' plan.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 26 * s),
            Material(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(40 * s),
              child: InkWell(
                borderRadius: BorderRadius.circular(40 * s),
                onTap: onHome,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40 * s, vertical: 16 * s),
                  child: Text('Go to Home', style: AppTextStyles.buttonLabel.scaled(s).copyWith(color: AppColors.black, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
