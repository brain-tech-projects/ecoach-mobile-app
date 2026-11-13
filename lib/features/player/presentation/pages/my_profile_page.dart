import 'package:ecoach_pro/core/utils/role_extensions.dart';
import 'package:ecoach_pro/features/coach_portal/presentation/pages/coach_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_loader.dart';
import 'package:ecoach_pro/core/widgets/app_primary_button.dart';
import 'package:ecoach_pro/core/widgets/sub_page_scaffold.dart';
import 'package:ecoach_pro/features/player/domain/entities/player_entities.dart';
import 'package:ecoach_pro/features/player/presentation/controllers/my_profile_controller.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/player_widgets.dart';
import 'package:ecoach_pro/features/player/presentation/widgets/profile_widgets.dart';

/// My Profile: banner + photo, then the editable player details.
class MyProfilePage extends GetView<MyProfileController> {
  const MyProfilePage({super.key});

  static List<SheetOption> _opts(List<String> v) =>
      <SheetOption>[for (final e in v) SheetOption(e, e)];

  @override
  Widget build(BuildContext context) {
    // Coaches see their own profile (controller is lazy, so no player API call).
    if (isCoachSession) return const CoachProfilePage();

    final r = Responsive.of(context);
    final s = r.scale;
    final c = controller;

    Widget gap([double v = 23.7]) => SizedBox(height: v * s);

    return SubPageScaffold(
      title: 'My Profile',
      body: Obx(() {
        if (c.loading.value) return const AppLoader();
        if (c.errorMessage.value != null) {
          return RetryMessage(message: c.errorMessage.value!, onRetry: c.load, scale: s);
        }
        final p = c.original.value!;
        final form = r.gutter + 32 * s;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(top: 28 * s, bottom: 24 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ---------- banner + avatar ----------
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.gutter + 12 * s),
                  child: _Header(profile: p, scale: s, onEditPhoto: c.onChangePhoto),
                ),
                SizedBox(height: 43 * s),
                // ---------- form ----------
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: form),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      UnderlineField(
                        label: 'Player Profile Name',
                        controller: c.profileName,
                        scale: s,
                        errorText: c.nameError.value,
                      ),
                      gap(),
                      UnderlineField(label: 'Player Full Name', controller: c.fullName, scale: s),
                      gap(),
                      UnderlineField(
                        label: 'Parent/Guardian Email',
                        controller: c.email,
                        scale: s,
                        keyboardType: TextInputType.emailAddress,
                        errorText: c.emailError.value,
                      ),
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
                            options: <SheetOption>[
                              for (final e in ProfileOptions.countries.entries)
                                SheetOption(e.key, e.value, leading: ProfileOptions.flag(e.key)),
                            ],
                          );
                          if (v != null) c.country.value = v;
                        },
                      ),
                      gap(),
                      UnderlineField(
                        label: 'My Club (displayed on profile)',
                        controller: c.club,
                        scale: s,
                      ),
                      gap(),
                      UnderlineField(
                        label: 'My Favourite Position (displayed on profile)',
                        controller: c.favPosition,
                        scale: s,
                      ),
                      gap(),
                      UnderlineField(
                        label: 'My Favourite Team',
                        controller: c.favTeam,
                        scale: s,
                        textInputAction: TextInputAction.done,
                      ),
                      gap(),
                      SelectBox(
                        label: 'Age',
                        text: c.age.value?.toString(),
                        scale: s,
                        onTap: () async {
                          final v = await showSingleSheet(
                            context,
                            title: 'Age',
                            selected: c.age.value?.toString(),
                            options: _opts(ProfileOptions.ages),
                          );
                          if (v != null) c.age.value = int.tryParse(v);
                        },
                      ),
                      gap(),
                      _multi(context, s, 'Playing Position', c.positions, ProfileOptions.positions),
                      gap(),
                      _multi(context, s, 'Current Level', c.levels, ProfileOptions.levels),
                      gap(),
                      _multi(context, s, 'Areas to Improve', c.improve, ProfileOptions.improve),
                      gap(),
                      SelectBox(
                        label: 'Biggest Difference',
                        text: c.biggestDifference.value,
                        scale: s,
                        onTap: () async {
                          final v = await showSingleSheet(
                            context,
                            title: 'Biggest Difference',
                            selected: c.biggestDifference.value,
                            options: _opts(ProfileOptions.biggestDifference),
                          );
                          if (v != null) c.biggestDifference.value = v;
                        },
                      ),
                      gap(),
                      SelectBox(
                        label: 'Training Frequency',
                        text: c.frequency.value,
                        scale: s,
                        onTap: () async {
                          final v = await showSingleSheet(
                            context,
                            title: 'Training Frequency',
                            selected: c.frequency.value,
                            options: _opts(ProfileOptions.frequency),
                          );
                          if (v != null) c.frequency.value = v;
                        },
                      ),
                      gap(),
                      DateUnderlineField(
                        label: 'Date Of Birth',
                        text: c.dob.value == null ? null : PlayerFormat.dob(c.dob.value!),
                        scale: s,
                        onTap: () => _pickDate(context),
                      ),
                      gap(48.7),
                      AppPrimaryButton(
                        label: 'Update Profile',
                        loading: c.saving.value,
                        onPressed: c.save,
                        scale: s,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _multi(BuildContext context, double s, String label, RxList<String> list, List<String> options) {
    return MultiSelectBox(
      label: label,
      values: List<String>.of(list),
      scale: s,
      onTap: () async {
        final v = await showMultiSheet(context, title: label, options: options, selected: list);
        if (v != null) list.assignAll(v);
      },
      onRemove: list.remove,
      onClear: list.clear,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.dob.value ?? DateTime(now.year - 12, now.month, now.day),
      firstDate: DateTime(now.year - 80),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: AppColors.black,
            surface: AppColors.popupBg,
            onSurface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) controller.dob.value = picked;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.scale, required this.onEditPhoto});

  final PlayerProfile profile;
  final double scale;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final avatar = 79.3 * s;

    Widget photo() {
      Widget fallback() => const ColoredBox(
            color: AppColors.avatarBg,
            child: Icon(Icons.person, color: AppColors.avatarFg, size: 40),
          );
      if (profile.photoAsset != null) {
        return Image.asset(profile.photoAsset!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback());
      }
      if (profile.photoUrl != null) {
        return Image.network(profile.photoUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback());
      }
      return fallback();
    }

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
                  child: ExcludeSemantics(
                    child: Image.asset(
                      'assets/images/player/profile_banner.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF14402F)),
                    ),
                  ),
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.white, width: 2.5 * s),
                            ),
                            child: ClipOval(child: ExcludeSemantics(child: photo())),
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
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
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
        Text(
          profile.profileName,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 20 * s,
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}
