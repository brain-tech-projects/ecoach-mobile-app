import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecoach_pro/core/services/api_service.dart';
import 'package:ecoach_pro/core/utils/validators.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';

class ContactController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final RxBool loading = false.obs;

  Future<void> submit() async {
    if (loading.value) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final message = messageController.text.trim();

    final problem = name.isEmpty
        ? 'Please enter your name.'
        : !Validators.isEmail(email)
        ? 'Please enter a valid email address.'
        : phone.isEmpty
        ? 'Please enter your phone number.'
        : message.isEmpty
        ? 'Please enter your message.'
        : null;
    if (problem != null) {
      AppToast.error(problem);
      return;
    }

    loading.value = true;
    try {
      final res = await _api.contactUs(
        name: name,
        email: email,
        phone: phone,
        issue: message,
      );
      if (!res.success) {
        AppToast.error(res.message);
        return;
      }
      AppToast.success(res.message);
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      messageController.clear();
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
