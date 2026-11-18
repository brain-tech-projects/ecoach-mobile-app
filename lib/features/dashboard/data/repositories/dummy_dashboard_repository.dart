import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/dashboard_stat.dart';
import 'package:ecoach_pro/features/dashboard/domain/entities/program.dart';
import 'package:ecoach_pro/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Static demo content (replace with the API-backed repository later).
class DummyDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardData> fetchDashboard() async {
    return const DashboardData(
      stats: <DashboardStat>[
        DashboardStat(
          iconAsset: AppAssets.statClock,
          value: '0',
          label: 'Matches tracked',
        ),
        DashboardStat(
          iconAsset: AppAssets.statTrophy,
          value: '0',
          label: 'Trophies',
        ),
        DashboardStat(
          iconAsset: AppAssets.statCoin,
          value: '0.00',
          label: 'Reward Points',
        ),
        DashboardStat(
          iconAsset: AppAssets.statClip,
          value: '0/7',
          label: 'Training streak in last 7 days',
        ),
      ],
      programs: <Program>[
        Program(
          id: '1',
          title: 'What\'s New & Open Access',
          description: 'See the latest tricks, drills and updates.',
          thumbnail: AppAssets.programIconWhatsNew,
        ),
        Program(
          id: '2',
          title: 'The eCoach Program',
          description: 'Our tailored training program that takes you through 5 skill ..',
          thumbnail: AppAssets.programIconEcoach,
        ),
        Program(
          id: '3',
          title: 'Personal Training Program',
          description: 'Create and follow your own personal training plan',
          thumbnail: AppAssets.programIconPersonal,
        ),
        Program(
          id: '4',
          title: 'Match Tracker',
          description: 'Complete your rating card from your last match',
          thumbnail: AppAssets.programIconMatchTracker,
        ),
        Program(
          id: '5',
          title: 'Skills',
          description: 'Pick a skill area to focus on and practise',
          thumbnail: AppAssets.programIconSkills,
        ),
        Program(
          id: '6',
          title: 'Just For Fun',
          description: 'Enjoy quick quizzes and fun challenges.',
          thumbnail: AppAssets.programIconFun,
        ),
        Program(
          id: '7',
          title: 'My Skills',
          description: 'See your favorite skills all in one place',
          thumbnail: AppAssets.programIconMySkills,
        ),
        Program(
          id: '8',
          title: 'My Coaches Training',
          description: 'If you are linked to a team the sessions from your coach will appear here',
          thumbnail: AppAssets.programIconCoaches,
        ),
      ],
    );
  }
}
