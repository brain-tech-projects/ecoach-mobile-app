import 'package:ecoach_pro/app/routes/app_routes.dart';
import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/program.dart';
import 'package:ecoach_pro/features/skills/domain/entities/skills_entities.dart';

/// "Popular Programs" of the signed-in home. There is no API for this list
/// yet. Point `thumbnail` at your own assets (or URLs) to match the design.
abstract final class MemberPrograms {
  static const List<Program> all = <Program>[
    Program(
      id: 'whats-new',
      title: 'What\'s New & Open Access',
      description: 'See the latest tricks, drills and updates.',
      thumbnail: AppAssets.programWhatsNew,
      route: AppRoutes.skillList,
      routeArguments: SkillCategory.openAccess,
    ),
    Program(
      id: 'ecoach-program',
      title: 'The eCoach Program',
      description: 'Our tailored training program that takes you through '
          '5 skill levels to build your game.',
      thumbnail: AppAssets.programEcoach,
      route: AppRoutes.training,
    ),
    Program(
      id: 'personal-training-program',
      title: 'Personal Training Program',
      description: 'Create and follow your own personal training plan',
      thumbnail: AppAssets.programEcoach,
      route: AppRoutes.personalTraining,
    ),
    Program(
      id: 'match-tracker',
      title: 'Match Tracker',
      description: 'Complete your rating card from your last match',
      thumbnail: AppAssets.programWhatsNew,
      route: AppRoutes.ratingTracker,
    ),
    Program(
      id: 'skills',
      title: 'Skills',
      description: 'Pick a skill area to focus on and practise',
      thumbnail: AppAssets.programEcoach,
      route: AppRoutes.skills,
    ),
    Program(
      id: 'just-for-fun',
      title: 'Just For Fun',
      description: 'Enjoy quick quizzes and fun challenges.',
      thumbnail: AppAssets.programWhatsNew,
      route: AppRoutes.fun,
    ),
    Program(
      id: 'my-skills',
      title: 'My Skills',
      description: 'See your favorite skills all in one place',
      thumbnail: AppAssets.programEcoach,
      route: AppRoutes.mySkills,
    ),
    Program(
      id: 'coaches-training',
      title: 'My Coaches Training',
      description: 'If you are linked to a team the sessions from your coach '
          'will appear here',
      thumbnail: AppAssets.programWhatsNew,
      route: AppRoutes.coachTraining,
    ),
  ];
}
