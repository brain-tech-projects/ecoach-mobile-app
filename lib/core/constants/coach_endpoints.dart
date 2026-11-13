/// Coach-portal paths (relative to Env.baseUrl). Rename here if the backend differs.
abstract final class CoachEndpoints {
  static const String details = '/coach/details';

  static const String teams = '/coach/teams';
  static const String createTeam = '/coach/teams/create';
  static const String updateTeam = '/coach/teams/update';
  static const String deleteTeam = '/coach/teams/delete';
  static const String createGroup = '/coach/teams/groups/create';
  static const String deleteGroup = '/coach/teams/groups/delete';
  static const String addTeamPlayers = '/coach/teams/add-players';

  static const String players = '/coach/players';
  static const String playerDetails = '/coach/players/details';
  static const String invitePlayer = '/coach/players/invite';
  static const String notifyPlayers = '/coach/players/notify';

  static const String programs = '/coach/programs';
  static const String createProgram = '/coach/programs/create';
  static const String updateProgram = '/coach/programs/update';
  static const String deleteProgram = '/coach/programs/delete';
  static const String addProgramPlayers = '/coach/programs/add-players';
}
