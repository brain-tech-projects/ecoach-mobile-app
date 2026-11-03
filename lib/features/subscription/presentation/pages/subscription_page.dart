import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/subscription/domain/entities/subscription_plan.dart';
import 'package:ecoach_pro/features/subscription/presentation/controllers/subscription_controller.dart';

/// Plans screen. Opened from the menu, and automatically when the API answers
/// "Subscription required".
class SubscriptionPage extends GetView<SubscriptionController> {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final white = AppTextStyles.sectionTitle.scaled(s);

    return SubPageScaffold(
      title: 'Subscription',
      showNav: false,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          r.gutter + 24 * s,
          24 * s,
          r.gutter + 24 * s,
          24 * s + r.safeBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: AppLogoHorizontal(scale: s)),
            SizedBox(height: 18 * s),
            Text(
              'Unlock the full eCoach experience',
              textAlign: TextAlign.center,
              style: white,
            ),
            SizedBox(height: 4 * s),
            Text(
              'TAKE A 7 DAY FREE TRIAL',
              textAlign: TextAlign.center,
              style: white.copyWith(color: AppColors.selectGreen),
            ),
            SizedBox(height: 8 * s),
            Text(
              'Cancel Anytime',
              textAlign: TextAlign.center,
              style: AppTextStyles.programDesc.scaled(s),
            ),
            SizedBox(height: 22 * s),
            for (final plan in controller.plans) ...<Widget>[
              _PlanCard(
                plan: plan,
                features: controller.features,
                scale: s,
                onTap: () => controller.onPlanTap(plan),
              ),
              SizedBox(height: 26 * s),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.lock_outline, size: 18 * s, color: AppColors.hint),
                SizedBox(width: 8 * s),
                Text(
                  'Secure payments powered by Stripe',
                  style: AppTextStyles.programDesc.scaled(s),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.features,
    required this.scale,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final List<String> features;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final body = AppTextStyles.programDesc.scaled(s);

    return Semantics(
      button: true,
      label: '${plan.title} plan, ${plan.weeklyPrice} per week',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 14 * s),
              padding: EdgeInsets.fromLTRB(22 * s, 26 * s, 22 * s, 22 * s),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18 * s),
                border: Border.all(
                  color: AppColors.selectGreen.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      plan.title,
                      style: AppTextStyles.programTitle.scaled(s),
                    ),
                  ),
                  SizedBox(height: 10 * s),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                            text: plan.weeklyPrice,
                            style: AppTextStyles.sectionTitle
                                .scaled(s)
                                .copyWith(
                                  color: AppColors.selectGreen,
                                  fontSize: 22 * s,
                                ),
                          ),
                          TextSpan(text: ' /week', style: body),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * s),
                  Center(
                    child: Text(
                      '${plan.billingNote}\nafter free trial',
                      textAlign: TextAlign.center,
                      style: body,
                    ),
                  ),
                  SizedBox(height: 18 * s),
                  for (final feature in features)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10 * s),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.check,
                            size: 18 * s,
                            color: AppColors.selectGreen,
                          ),
                          SizedBox(width: 10 * s),
                          Expanded(
                            child: Text(
                              feature,
                              style: body.copyWith(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (plan.mostPopular)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 18 * s,
                  vertical: 6 * s,
                ),
                decoration: BoxDecoration(
                  color: AppColors.selectGreen,
                  borderRadius: BorderRadius.circular(14 * s),
                ),
                child: Text(
                  'MOST POPULAR',
                  style: AppTextStyles.heroButton.scaled(s),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
