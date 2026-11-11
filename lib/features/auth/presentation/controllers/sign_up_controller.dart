import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/network/api_response.dart';
import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/utils/validators.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/auth/data/countries_data.dart';
import 'package:ecoach_pro/features/auth/data/signup_content.dart';
import 'package:ecoach_pro/features/auth/domain/entities/country.dart';
import 'package:ecoach_pro/features/auth/domain/entities/otp_args.dart';
import 'package:ecoach_pro/features/auth/domain/entities/programme_summary.dart';
import 'package:ecoach_pro/features/auth/domain/entities/signup_step.dart';
import 'package:ecoach_pro/features/auth/domain/entities/user_role.dart';

/// State of the whole sign-up flow (all screens share this controller).
class SignUpController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxBool isLoading = false.obs;

  // ---- Flow ----------------------------------------------------------------
  final Rx<UserRole> selectedRole = UserRole.player.obs;
  final RxInt stepIndex = 0.obs;

  /// Selected option ids per step (single choice keeps exactly one id).
  final RxMap<SignUpStepKind, List<String>> answers =
      <SignUpStepKind, List<String>>{}.obs;

  // ---- Account form ----------------------------------------------------------
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final Rx<Country> country = Countries.india.obs;

  final RxnString emailError = RxnString();
  final RxnString nameError = RxnString();
  final RxnString passwordError = RxnString();

  /// Bumped on every keystroke so the "valid" (green) border can react.
  final RxInt formTick = 0.obs;

  bool _submitted = false;

  List<SignUpStepKind> get flow => selectedRole.value.flow;
  SignUpStepKind get currentKind => flow[stepIndex.value];
  int get stepNumber => stepIndex.value + 1;
  int get totalSteps => flow.length;
  bool get isCoach => selectedRole.value == UserRole.coach;
  bool get isLastStep => stepIndex.value == flow.length - 1;

  @override
  void onInit() {
    super.onInit();
    for (final c in <TextEditingController>[
      emailController,
      nameController,
      passwordController,
    ]) {
      c.addListener(() => formTick.value++);
    }
  }

  // ---- Role ------------------------------------------------------------------
  void selectRole(UserRole role) => selectedRole.value = role;

  // ---- Choices ---------------------------------------------------------------
  List<String> selected(SignUpStepKind kind) =>
      answers[kind] ?? const <String>[];

  bool isSelected(SignUpStepKind kind, String id) =>
      selected(kind).contains(id);

  void select(SignUpStepKind kind, String id, {required bool multiple}) {
    final current = selected(kind);
    if (!multiple) {
      answers[kind] = <String>[id];
      return;
    }
    answers[kind] = current.contains(id)
        ? (List<String>.of(current)..remove(id))
        : <String>[...current, id];
  }

  /// "Next" is enabled once a choice step has at least one selection.
  bool get canProceed {
    switch (currentKind) {
      case SignUpStepKind.role:
      case SignUpStepKind.account:
        return true;
      default:
        return selected(currentKind).isNotEmpty;
    }
  }

  // ---- Navigation ------------------------------------------------------------
  void onBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (stepIndex.value > 0) {
      stepIndex.value--;
    } else {
      Get.back<void>();
    }
  }

  void onNext() {
    if (!canProceed) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (isLastStep) {
      submit();
    } else {
      stepIndex.value++;
    }
  }

  void openSignIn() => Get.offNamed<void>(AppRoutes.signIn);

  // ---- Account form ----------------------------------------------------------
  bool get isEmailValid {
    formTick.value; // ignore: unnecessary_statements
    return Validators.isEmail(emailController.text);
  }

  bool get isNameValid {
    formTick.value; // ignore: unnecessary_statements
    return nameController.text.trim().isNotEmpty;
  }

  bool get isPasswordValid {
    formTick.value; // ignore: unnecessary_statements
    return passwordController.text.isNotEmpty;
  }

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  void selectCountry(Country value) => country.value = value;

  void onEmailChanged(String _) {
    if (_submitted) emailError.value = _emailMessage();
  }

  void onNameChanged(String _) {
    if (_submitted) nameError.value = _nameMessage();
  }

  void onPasswordChanged(String _) {
    if (_submitted) passwordError.value = _passwordMessage();
  }

  String? _emailMessage() {
    final value = emailController.text;
    final required = Validators.requiredField(value, 'Email');
    if (required != null) return required;
    return Validators.isEmail(value)
        ? null
        : 'The Email must be a valid email address.';
  }

  String? _nameMessage() =>
      Validators.requiredField(nameController.text, 'Profile Name');

  String? _passwordMessage() =>
      Validators.requiredField(passwordController.text, 'Password');

  bool _validate() {
    emailError.value = _emailMessage();
    nameError.value = _nameMessage();
    passwordError.value = _passwordMessage();
    return emailError.value == null &&
        nameError.value == null &&
        passwordError.value == null;
  }

  /// Ages 5-12 -> parent/guardian email must be verified with an OTP.
  bool get requiresOtp {
    final raw = selected(SignUpStepKind.age).firstOrNull;
    final age = raw == null ? null : int.tryParse(raw);
    return age != null && age <= SignUpContent.maxAgeRequiringOtp;
  }

  /// Labels of the selected options (the backend stores the label text,
  /// e.g. "Just starting out"). `1× a week` is sent as `1x a week`.
  List<String>? _labels(SignUpStepKind kind) {
    final ids = selected(kind);
    final question = SignUpContent.questionFor(kind);
    if (ids.isEmpty || question == null) return null;
    return question.options
        .where((o) => ids.contains(o.id))
        .map((o) => o.label.replaceAll('×', 'x'))
        .toList();
  }

  int? get _age {
    final raw = selected(SignUpStepKind.age).firstOrNull;
    return raw == null ? null : int.tryParse(raw);
  }

  /// Display labels (keeps `×`), joined for the "programme is ready" card.
  String _display(SignUpStepKind kind) {
    final ids = selected(kind);
    final question = SignUpContent.questionFor(kind);
    if (ids.isEmpty || question == null) return '';
    return question.options
        .where((o) => ids.contains(o.id))
        .map((o) => o.label)
        .join(', ');
  }

  ProgrammeSummary _buildSummary() {
    final age = _age;
    return ProgrammeSummary(
      age: age == null ? '' : (age >= 13 ? '13+ years old' : '$age years old'),
      positions: _display(SignUpStepKind.positions),
      level: _display(SignUpStepKind.level),
      focus: _display(SignUpStepKind.improve),
      goals: _display(SignUpStepKind.difference),
      frequency: _display(SignUpStepKind.frequency),
    );
  }

  /// Email field label: player / parent-guardian (ages 5-12) / coach.
  String get emailLabel {
    if (isCoach) return 'Coach Email *';
    if (requiresOtp || selectedRole.value == UserRole.parent) {
      return 'Parent/Guardian Email *';
    }
    return 'Player Email *';
  }

  Future<void> submit() async {
    if (isLoading.value) return;
    _submitted = true;
    if (!_validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final needsOtp = !isCoach && requiresOtp;

    isLoading.value = true;
    try {
      final res = await _api.register(
        fullName: nameController.text.trim(),
        email: email,
        password: password,
        role: selectedRole.value.apiValue,
        country: country.value.name,
        countryCode: country.value.code,
        age: isCoach ? null : _age,
        // Ages 5-12: the email entered IS the parent/guardian email.
        parentGuardianEmail: needsOtp ? email : null,
        playingPosition: _labels(SignUpStepKind.positions),
        skillLevel: _labels(SignUpStepKind.level),
        improveAreas: _labels(SignUpStepKind.improve),
        biggestDifference: _labels(SignUpStepKind.difference),
        trainingFrequency: _labels(SignUpStepKind.frequency),
      );

      if (!res.success) {
        _showError(res);
        return;
      }

            final user = res.data;

      final programmeArgs = isCoach
          ? null
          : ProgrammeArgs(
              email: email,
              password: password,
              summary: _buildSummary(),
            );

      if (needsOtp || (user?.isInactive ?? false)) {
        // Backend mailed an OTP to the parent / guardian.
        AppToast.success(res.message);
        Get.toNamed<void>(
          AppRoutes.otp,
          arguments: OtpArgs(
            email: email,
            purpose: OtpPurpose.signUp,
            userId: user?.id,
            password: password,
            programme: programmeArgs,
          ),
        );
        return;
      }

      if (programmeArgs != null) {
        // Players / parents: programme screens, then sign in on "Unlock".
        AppToast.success('User Registered Successfully.');
        Get.offAllNamed<void>(AppRoutes.programme, arguments: programmeArgs);
        return;
      }

      // Coach: register returns no token, so sign in right away.
      final login = await _api.login(email: email, password: password);
      if (login.success) {
        Get.offAllNamed<void>(AppRoutes.dashboard);
      } else {
        AppToast.success('Account created. Please sign in.');
        Get.offNamed<void>(AppRoutes.signIn);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Field errors go under their input, everything else is a toast.
  void _showError(ApiResponse<dynamic> res) {
    final email = res.fieldError('email');
    final name = res.fieldError('full_name');
    final password = res.fieldError('password');
    if (email != null) emailError.value = email;
    if (name != null) nameError.value = name;
    if (password != null) passwordError.value = password;

    if (email == null && name == null && password == null) {
      // e.g. "The email has already been taken."
      if (res.message.toLowerCase().contains('email')) {
        emailError.value = res.message;
      } else {
        AppToast.error(res.message);
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
