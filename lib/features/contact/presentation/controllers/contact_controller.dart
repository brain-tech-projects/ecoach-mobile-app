import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  void submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    // TODO(api): send name, email, phone and message to the support endpoint.
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
