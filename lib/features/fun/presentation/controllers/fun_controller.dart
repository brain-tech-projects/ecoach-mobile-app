import 'package:get/get.dart';

import 'package:ecoach_pro/app/routes/app_routes.dart';

class FunController extends GetxController {
  void openChallenges() => Get.toNamed<void>(AppRoutes.challenges);

  void openQuizzes() => Get.toNamed<void>(AppRoutes.quizzes);
}
