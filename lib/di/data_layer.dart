import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../data/data_sources/local_data_source.dart';
import '../data/data_sources/shared_preferences_local_data_source.dart';
import '../data/repositories/player_data_repository_impl.dart';
import '../domain/repositories/player_data_repository.dart';
import '../services/game_data_service.dart';

/// Dependency Injection container for the data layer
class DataLayer {
  static SharedPreferences? _prefs;
  static LocalDataSource? _localDataSource;
  static PlayerDataRepository? _playerDataRepository;
  static GameDataService? _gameDataService;
  static bool _isInitialized = false;

  /// Initialize the data layer (call this in main())
  static Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing DataLayer: $e');
      rethrow;
    }
  }

  /// Check if the data layer is initialized
  static bool get isInitialized => _isInitialized;

  /// Get the SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('DataLayer not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  /// Get the LocalDataSource instance (singleton)
  static LocalDataSource get localDataSource {
    _localDataSource ??= SharedPreferencesLocalDataSource(prefs);
    return _localDataSource!;
  }

  /// Get the PlayerDataRepository instance (singleton)
  static PlayerDataRepository get playerDataRepository {
    _playerDataRepository ??= PlayerDataRepositoryImpl(localDataSource);
    return _playerDataRepository!;
  }

  /// Get the GameDataService instance (singleton)
  static GameDataService get gameDataService {
    if (!_isInitialized) {
      throw Exception('DataLayer not initialized. Call initialize() first.');
    }
    _gameDataService ??= GameDataService(playerDataRepository);
    return _gameDataService!;
  }

  /// Reset all instances (useful for testing)
  static void reset() {
    _prefs = null;
    _localDataSource = null;
    _playerDataRepository = null;
    _gameDataService = null;
    _isInitialized = false;
  }
}
