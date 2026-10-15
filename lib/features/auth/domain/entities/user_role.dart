/// Who the account is for. [totalSteps] is the length of that sign-up flow
/// (players and parents: 8 steps, coaches: 2 steps).
enum UserRole {
  player(label: 'I\'m a Player', totalSteps: 8),
  coach(label: 'I\'m a Coach', totalSteps: 2),
  parent(label: 'I\'m a Parent', totalSteps: 8);

  const UserRole({required this.label, required this.totalSteps});

  final String label;
  final int totalSteps;
}
