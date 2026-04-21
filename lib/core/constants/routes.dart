class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String profile = 'profile'; // sub-route
  static const String leaderboard = 'leaderboard'; // sub-route
  static const String lobby = '/lobby';
  static const String waiting = 'waiting/:roomCode'; // sub-route
  static const String game = '/game/:roomCode';
  static const String result = '/result/:roomCode';
}
