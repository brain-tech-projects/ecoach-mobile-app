import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/controllers/coach_profile_controller.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/profile_widgets.dart';

/// Coach "My Profile" (shown by MyProfilePage when the role is Coach).
class CoachProfilePage extends StatefulWidget {
  const CoachProfilePage({super.key});

  @override
  State<CoachProfilePage> createState() => _CoachProfilePageState();
}

class _CoachProfilePageState extends State<CoachProfilePage> {
  late final CoachProfileController c = Get.put(CoachProfileController());

  @override
  void dispose() {
    Get.delete<CoachProfileController>();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: c.dob.value ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(now.year - 90),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.accent, onPrimary: AppColors.black, surface: AppColors.popupBg, onSurface: AppColors.white)),
        child: child!,
      ),
    );
    if (picked != null) c.dob.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final s = r.scale;
    final form = r.gutter + 32 * s;
    Widget gap([double v = 23.7]) => SizedBox(height: v * s);

    return SubPageScaffold(
      title: 'My Profile',
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(top: 28 * s, bottom: 24 * s),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.gutter + 12 * s),
                  child: _Header(name: c.displayName.value, photoPath: c.photoPath.value, scale: s, onEditPhoto: c.changePhoto),
                ),
                SizedBox(height: 43 * s),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: form),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      UnderlineField(label: 'Coach Profile Name', controller: c.profileName, scale: s, errorText: c.nameError.value),
                      gap(),
                      UnderlineField(label: 'Coach Full Name', controller: c.fullName, scale: s),
                      gap(),
                      UnderlineField(label: 'Coach Email', controller: c.email, scale: s, keyboardType: TextInputType.emailAddress, errorText: c.emailError.value),
                      gap(),
                      SelectBox(
                        label: 'Country',
                        leading: ProfileOptions.flag(c.country.value),
                        text: ProfileOptions.countries[c.country.value] ?? c.country.value,
                        scale: s,
                        onTap: () async {
                          final v = await showSingleSheet(
                            context,
                            title: 'Country',
                            selected: c.country.value,
                            options: <SheetOption>[for (final e in ProfileOptions.countries.entries) SheetOption(e.key, e.value, leading: ProfileOptions.flag(e.key))],
                          );
                          if (v != null) c.country.value = v;
                        },
                      ),
                      gap(),
                      UnderlineField(label: 'My Team', controller: c.team, scale: s),
                      gap(),
                      UnderlineField(label: 'Favourite Position', controller: c.position, scale: s, textInputAction: TextInputAction.done),
                      gap(),
                      DateUnderlineField(label: 'Date Of Birth', text: c.dob.value == null ? null : PlayerFormat.dob(c.dob.value!), scale: s, onTap: () => _pickDate(context)),
                      gap(48.7),
                      AppPrimaryButton(label: 'Update Profile', loading: c.saving.value, onPressed: c.save, scale: s),
                    ],
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

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.photoPath, required this.scale, required this.onEditPhoto});
  final String name;
  final String? photoPath;
  final double scale;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final avatar = 79.3 * s;
    const fallback = ColoredBox(color: AppColors.avatarBg, child: Icon(Icons.person, color: AppColors.avatarFg, size: 40));

    return Column(
      children: <Widget>[
        SizedBox(
          height: 157 * s + avatar - 42.7 * s,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 157 * s,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28 * s),
                  child: ExcludeSemantics(child: Image.asset('assets/images/player/profile_banner.png', fit: BoxFit.cover, errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF14402F)))),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: avatar,
                    height: avatar,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.white, width: 2.5 * s)),
                            child: ClipOval(
                              child: ExcludeSemantics(
                                child: photoPath == null ? fallback : Image.file(File(photoPath!), fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 1.5 * s,
                          bottom: 1.5 * s,
                          child: Semantics(
                            button: true,
                            label: 'Change profile photo',
                            child: GestureDetector(
                              onTap: onEditPhoto,
                              child: Container(
                                width: 24.7 * s,
                                height: 24.7 * s,
                                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                child: Icon(Icons.edit_outlined, size: 14 * s, color: AppColors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * s),
        Text(name, textAlign: TextAlign.center, style: TextStyle(fontFamily: AppTextStyles.fontFamily, fontSize: 20 * s, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.white)),
      ],
    );
  }
}
