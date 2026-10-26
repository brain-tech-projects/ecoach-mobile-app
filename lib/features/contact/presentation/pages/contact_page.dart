import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_logo_horizontal.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:ecoach_pro/features/contact/presentation/controllers/contact_controller.dart';

class ContactPage extends GetView<ContactController> {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final gap = SizedBox(height: 16.7 * s);

    return SubPageScaffold(
      title: 'Contact us',
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          r.gutter + 24 * s,
          44.3 * s,
          r.gutter + 24 * s,
          24 * s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(child: AppLogoHorizontal(scale: s)),
            SizedBox(height: 21.9 * s),
            Semantics(
              header: true,
              child: Text(
                'Need any help?',
                textAlign: TextAlign.center,
                style: AppTextStyles.contactTitle.scaled(s),
              ),
            ),
            SizedBox(height: 5.1 * s),
            Text.rich(
              TextSpan(
                text: 'Contact us at ',
                children: <InlineSpan>[
                  TextSpan(
                    text: 'info@ecoachpro.net',
                    style: AppTextStyles.contactEmail.scaled(s),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              style: AppTextStyles.contactSubtitle.scaled(s),
            ),
            SizedBox(height: 24.7 * s),
            AuthTextField(
              controller: controller.nameController,
              hint: 'Enter your name',
              iconAsset: AppAssets.iconUser,
              iconWidth: 15.7,
              iconHeight: 19.3,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              scale: s,
            ),
            gap,
            AuthTextField(
              controller: controller.emailController,
              hint: 'abc@email.com',
              iconAsset: AppAssets.iconMail,
              iconWidth: 19.3,
              iconHeight: 17.3,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              scale: s,
            ),
            gap,
            AuthTextField(
              controller: controller.phoneController,
              hint: 'Enter Phone Number',
              iconAsset: AppAssets.iconPhone,
              iconWidth: 19.3,
              iconHeight: 19.3,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              scale: s,
            ),
            gap,
            AuthTextField(
              controller: controller.messageController,
              hint: 'Enter Message here ...',
              iconAsset: AppAssets.iconPencil,
              iconWidth: 18,
              iconHeight: 17.7,
              height: 109.3,
              multiline: true,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              scale: s,
            ),
            SizedBox(height: 24.6 * s),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * s),
              child: AppPrimaryButton(
                label: 'Submit',
                onPressed: controller.submit,
                scale: s,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
