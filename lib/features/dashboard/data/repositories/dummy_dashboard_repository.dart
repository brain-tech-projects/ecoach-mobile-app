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
          thumbnail: AppAssets.programWhatsNew,
        ),
        Program(
          id: '2',
          title: 'The eCoach Program',
          description: 'Our tailored training program that takes you '
              'through 5 skill levels to build your game.',
          thumbnail: AppAssets.programEcoach,
        ),
        Program(
          id: '3',
          title: 'Skills Mastery',
          description: 'Build a personal training plan around the skills '
              'you want to master.',
          thumbnail: AppAssets.programEcoach,
        ),
        Program(
          id: '4',
          title: 'Fitness & Conditioning',
          description: 'Boost your speed, stamina and strength with '
              'football-specific workouts.',
          thumbnail: AppAssets.programWhatsNew,
        ),
        Program(
          id: '5',
          title: 'Match Day Ready',
          description: 'Warm-ups and routines to get you game-ready.',
          thumbnail: AppAssets.programEcoach,
        ),
        Program(
          id: '6',
          title: 'Parents Guide',
          description: 'Support your young player\'s journey at home.',
          thumbnail: AppAssets.programWhatsNew,
        ),
      ],
    );
  }
}
