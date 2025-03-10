abstract class Config {
  // Using picsum photos API for the photo album
  static const String apiBaseUrl = 'https://picsum.photos';
  static const int itemsPerPage = 10;

  // Set this to true to enable additional logging in release mode
  static const bool enableDebugInRelease = true;

  // API timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Cache settings
  static const int cacheDurationHours = 24; // Cache validity in hours
}
