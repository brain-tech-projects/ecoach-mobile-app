abstract final class AppAssets {
  static const String _images = 'assets/images';
  static const String _icons = '$_images/icons';

  // Logos (logo.png is resolution-aware: 2.0x/ and 3.0x/ variants)
  static const String logo = '$_images/logo.png';
  static const String logoHorizontal = '$_images/logo_horizontal.png';

  // Role icons (white masks - tinted at runtime)
  static const String iconPlayer = '$_icons/player.png';
  static const String iconWhistle = '$_icons/whistle.png';
  static const String iconParents = '$_icons/parents.png';

  // Form icons
  static const String iconMail = '$_icons/mail.png';
  static const String iconLock = '$_icons/lock.png';
  static const String iconEyeOff = '$_icons/eye_off.png';

  // Dashboard
  static const String iconMenu = '$_icons/menu.png';
  static const String statClock = '$_icons/stat_clock.png';
  static const String statTrophy = '$_icons/stat_trophy.png';
  static const String statCoin = '$_icons/stat_coin.png';
  static const String statClip = '$_icons/stat_clip.png';

  static const String navTraining = '$_icons/nav_training.png';
  static const String navSkills = '$_icons/nav_skills.png';
  static const String navHome = '$_icons/nav_home.png';
  static const String navFun = '$_icons/nav_fun.png';
  static const String navTracker = '$_icons/nav_tracker.png';

  // Dummy program thumbnails (replace with API images later)
  static const String programWhatsNew = '$_images/program_whats_new.png';
  static const String programEcoach = '$_images/program_ecoach.png';
}
