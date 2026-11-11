import 'package:flutter/foundation.dart';

import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// Route arguments of the "Play All" queue player.
@immutable
class PersonalTrainingPlayerArgs {
  const PersonalTrainingPlayerArgs({required this.drills, this.startIndex = 0});

  final List<Drill> drills;
  final int startIndex;
}
