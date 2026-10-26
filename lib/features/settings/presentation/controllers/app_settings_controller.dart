import 'package:get/get.dart';

class AppSettingsController extends GetxController {
  /// "Terms of Use" accordion state (collapsed when the page opens).
  final RxBool termsExpanded = false.obs;

  void toggleTerms() => termsExpanded.value = !termsExpanded.value;
}
