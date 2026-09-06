// ────────────────────────────────────────────────────────────────────────────
// App-wide constants
// ────────────────────────────────────────────────────────────────────────────

class AppConstants {
  static const String appName = 'Music';
  static const String defaultAuthor = 'Unknown Artist';
  static const String defaultTitle = 'Unknown Title';

  // Supported audio file extensions
  static const List<String> allowedExtensions = [
    'mp3', 'm4a', 'flac', 'wav', 'ogg', 'aac'
  ];

  // ZIP export metadata filename
  static const String metadataFileName = 'metadata.json';
  static const String songsFolder = 'songs';
  static const String coversFolder = 'covers';

  // Hive type IDs
  static const int songTypeId = 0;
  static const int playlistTypeId = 1;
}
