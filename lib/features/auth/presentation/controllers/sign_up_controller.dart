import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/utils/validators.dart';
import 'package:ecoach_pro/features/auth/data/countries_data.dart';
import 'package:ecoach_pro/features/auth/data/signup_content.dart';
import 'package:ecoach_pro/features/auth/domain/entities/country.dart';
import 'package:ecoach_pro/features/auth/domain/entities/signup_step.dart';
import 'package:ecoach_pro/features/auth/domain/entities/user_role.dart';

/// State of the whole sign-up flow (all screens share this controller).
class SignUpController extends GetxController {
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

  void submit() {
    _submitted = true;
    if (!_validate()) return;

    // TODO(api): create the account with the collected answers + form values.
    if (!isCoach && requiresOtp) {
      Get.toNamed<void>(
        AppRoutes.otp,
        arguments: emailController.text.trim(),
      );
    } else {
      Get.offAllNamed<void>(AppRoutes.dashboard);
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
