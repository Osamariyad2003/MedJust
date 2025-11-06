class AppConstants {
  static const String appName = 'Med Just';
  static const String version = '1.0.0';



  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';

  // Route Names
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String yearsRoute = '/years';
  static const String subjectsRoute = '/subjects';
  static const String lecturesRoute = '/lectures';
  static const String videosRoute = '/videos';
  static const String filesRoute = '/files';
  static const String quizzesRoute = '/quizzes';
  static const String professorsRoute = '/professors';
  static const String newsRoute = '/news';
  static const String storeRoute = '/store';
  static const String gpaCalculatorRoute = '/gpa-calculator';
  static const String universityMapRoute = '/university-map';

  // Timeouts
  static const int connectionTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
}
