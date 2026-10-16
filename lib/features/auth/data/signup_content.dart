import 'package:ecoach_pro/core/constants/app_assets.dart';
import 'package:ecoach_pro/features/auth/domain/entities/choice.dart';
import 'package:ecoach_pro/features/auth/domain/entities/signup_step.dart';
import 'package:ecoach_pro/features/auth/domain/entities/user_role.dart';

/// Copy and options for every sign-up screen (same for player and parent).
abstract final class SignUpContent {
  /// Ages 5-12 need parental email verification (OTP); 13+ does not.
  static const int maxAgeRequiringOtp = 12;

  static const List<ChoiceOption> ageOptions = <ChoiceOption>[
    ChoiceOption(id: '5', label: '5'),
    ChoiceOption(id: '6', label: '6'),
    ChoiceOption(id: '7', label: '7'),
    ChoiceOption(id: '8', label: '8'),
    ChoiceOption(id: '9', label: '9'),
    ChoiceOption(id: '10', label: '10'),
    ChoiceOption(id: '11', label: '11'),
    ChoiceOption(id: '12', label: '12'),
    ChoiceOption(id: '13', label: '13+'),
  ];

  static const ChoiceQuestion positions = ChoiceQuestion(
    title: 'What position do they play? (Select all that apply)',
    subtitle: 'This helps us tailor position-specific training.',
    multiple: true,
    options: <ChoiceOption>[
      ChoiceOption(
        id: 'goalkeeper',
        label: 'Goalkeeper',
        iconAsset: AppAssets.choiceGoalkeeper,
      ),
      ChoiceOption(
        id: 'defender',
        label: 'Defender',
        iconAsset: AppAssets.choiceDefender,
      ),
      ChoiceOption(
        id: 'midfielder',
        label: 'Midfielder',
        iconAsset: AppAssets.choiceMidfielder,
      ),
      ChoiceOption(
        id: 'winger',
        label: 'Winger',
        iconAsset: AppAssets.choiceWinger,
      ),
      ChoiceOption(
        id: 'striker',
        label: 'Striker',
        iconAsset: AppAssets.choiceStriker,
      ),
      ChoiceOption(
        id: 'no_set_position',
        label: 'No set position',
        iconAsset: AppAssets.choiceNoSetPosition,
      ),
    ],
  );

  static const ChoiceQuestion level = ChoiceQuestion(
    title: 'How would you describe their current level?',
    subtitle: 'Select all that apply.',
    multiple: true,
    options: <ChoiceOption>[
      ChoiceOption(
        id: 'starting_out',
        label: 'Just starting out',
        iconAsset: AppAssets.choiceStar,
      ),
      ChoiceOption(
        id: 'developing',
        label: 'Developing',
        iconAsset: AppAssets.choiceTrend,
      ),
      ChoiceOption(
        id: 'confident',
        label: 'Confident player',
        iconAsset: AppAssets.choiceTrophy,
      ),
      ChoiceOption(
        id: 'advanced',
        label: 'Advanced',
        iconAsset: AppAssets.choiceRocket,
      ),
    ],
  );

  static const ChoiceQuestion improve = ChoiceQuestion(
    title: 'What would they most like to improve?',
    subtitle: 'Choose as many as you like.',
    multiple: true,
    options: <ChoiceOption>[
      ChoiceOption(
        id: 'dribbling',
        label: 'Dribbling',
        iconAsset: AppAssets.choiceDribbling,
      ),
      ChoiceOption(
        id: 'first_touch',
        label: 'First touch',
        iconAsset: AppAssets.choiceFirstTouch,
      ),
      ChoiceOption(
        id: 'passing',
        label: 'Passing',
        iconAsset: AppAssets.choicePassing,
      ),
      ChoiceOption(
        id: 'shooting',
        label: 'Shooting',
        iconAsset: AppAssets.choiceShooting,
      ),
      ChoiceOption(
        id: 'skills_tricks',
        label: 'Skills & tricks',
        iconAsset: AppAssets.choiceStar,
      ),
      ChoiceOption(
        id: 'speed_fitness',
        label: 'Speed & fitness',
        iconAsset: AppAssets.choiceDumbbell,
      ),
      ChoiceOption(
        id: 'all_round',
        label: 'All-round game',
        iconAsset: AppAssets.choiceAllRound,
      ),
    ],
  );

  static const ChoiceQuestion difference = ChoiceQuestion(
    title: 'What would make the biggest difference?',
    subtitle: 'Choose as many as you like.',
    multiple: true,
    options: <ChoiceOption>[
      ChoiceOption(
        id: 'confidence',
        label: 'More confidence',
        iconAsset: AppAssets.choiceConfidence,
      ),
      ChoiceOption(
        id: 'technique',
        label: 'Better technique',
        iconAsset: AppAssets.choiceGear,
      ),
      ChoiceOption(
        id: 'practice',
        label: 'Practising more often',
        iconAsset: AppAssets.choiceCalendarGrid,
      ),
      ChoiceOption(
        id: 'matches',
        label: 'Standing out in matches',
        iconAsset: AppAssets.choiceStar,
      ),
      ChoiceOption(
        id: 'new_skills',
        label: 'Learning new skills',
        iconAsset: AppAssets.choiceBulb,
      ),
      ChoiceOption(
        id: 'fitter',
        label: 'Getting fitter',
        iconAsset: AppAssets.choiceHeart,
      ),
    ],
  );

  static const ChoiceQuestion frequency = ChoiceQuestion(
    title: 'How often would they like to train?',
    subtitle: 'We\'ll build a plan around this.',
    multiple: false,
    options: <ChoiceOption>[
      ChoiceOption(
        id: '1',
        label: '1× a week',
        iconAsset: AppAssets.choiceCalendar,
      ),
      ChoiceOption(
        id: '2',
        label: '2× a week',
        iconAsset: AppAssets.choiceCalendar,
      ),
      ChoiceOption(
        id: '3',
        label: '3× a week',
        iconAsset: AppAssets.choiceCalendar,
      ),
      ChoiceOption(
        id: 'max',
        label: 'As much as possible',
        iconAsset: AppAssets.choiceUnlimited,
      ),
    ],
  );

  /// The option list of a choice step (`null` for role / age / account).
  static ChoiceQuestion? questionFor(SignUpStepKind kind) => switch (kind) {
    SignUpStepKind.positions => positions,
    SignUpStepKind.level => level,
    SignUpStepKind.improve => improve,
    SignUpStepKind.difference => difference,
    SignUpStepKind.frequency => frequency,
    _ => null,
  };

  static StepHeader headerFor(SignUpStepKind kind, UserRole role) {
    switch (kind) {
      case SignUpStepKind.role:
        return const StepHeader(
          title: 'Who is this for?',
          subtitle: 'This helps us create the right experience for you.',
        );
      case SignUpStepKind.age:
        return const StepHeader(
          title: 'How old is the player?',
          subtitle: 'Select the age that best applies.',
        );
      case SignUpStepKind.account:
        return StepHeader(
          title: role == UserRole.coach
              ? 'Create your account'
              : 'While we create your programme...',
          subtitle: 'Please give us a few details.',
        );
      case SignUpStepKind.positions:
      case SignUpStepKind.level:
      case SignUpStepKind.improve:
      case SignUpStepKind.difference:
      case SignUpStepKind.frequency:
        final q = questionFor(kind)!;
        return StepHeader(title: q.title, subtitle: q.subtitle);
    }
  }
}
