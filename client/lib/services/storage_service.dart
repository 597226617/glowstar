import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Storage Service for GlowStar
/// 
/// Manages local file storage and caching
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Directory? _appDirectory;
  Directory? _cacheDirectory;

  /// Initialize storage
  Future<void> initialize() async {
    _appDirectory = await getApplicationDocumentsDirectory();
    _cacheDirectory = await getTemporaryDirectory();

    // Create necessary directories
    await _createDirectoryIfNotExists('${_appDirectory!.path}/images');
    await _createDirectoryIfNotExists('${_appDirectory!.path}/documents');
    await _createDirectoryIfNotExists('${_appDirectory!.path}/audio');
    await _createDirectoryIfNotExists('${_appDirectory!.path}/videos');
  }

  /// Get app directory
  Directory get appDirectory => _appDirectory!;

  /// Get cache directory
  Directory get cacheDirectory => _cacheDirectory!;

  /// Save file to app storage
  Future<String> saveFile(String subDirectory, String filename, List<int> data) async {
    String dirPath = '${_appDirectory!.path}/$subDirectory';
    await _createDirectoryIfNotExists(dirPath);

    String filePath = '$dirPath/$filename';
    File file = File(filePath);
    await file.writeAsBytes(data);

    return filePath;
  }

  /// Read file from app storage
  Future<List<int>?> readFile(String subDirectory, String filename) async {
    String filePath = '${_appDirectory!.path}/$subDirectory/$filename';
    File file = File(filePath);

    if (await file.exists()) {
      return await file.readAsBytes();
    }

    return null;
  }

  /// Delete file from app storage
  Future<bool> deleteFile(String subDirectory, String filename) async {
    String filePath = '${_appDirectory!.path}/$subDirectory/$filename';
    File file = File(filePath);

    if (await file.exists()) {
      await file.delete();
      return true;
    }

    return false;
  }

  /// Save to cache
  Future<String> saveToCache(String filename, List<int> data) async {
    String filePath = '${_cacheDirectory!.path}/$filename';
    File file = File(filePath);
    await file.writeAsBytes(data);

    return filePath;
  }

  /// Read from cache
  Future<List<int>?> readFromCache(String filename) async {
    String filePath = '${_cacheDirectory!.path}/$filename';
    File file = File(filePath);

    if (await file.exists()) {
      return await file.readAsBytes();
    }

    return null;
  }

  /// Clear cache
  Future<void> clearCache() async {
    if (await _cacheDirectory!.exists()) {
      await _cacheDirectory!.delete(recursive: true);
      await _cacheDirectory!.create();
    }
  }

  /// Get file size
  Future<int> getFileSize(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// List files in directory
  Future<List<String>> listFiles(String subDirectory) async {
    String dirPath = '${_appDirectory!.path}/$subDirectory';
    Directory dir = Directory(dirPath);

    if (await dir.exists()) {
      return dir.listSync().map((file) => path.basename(file.path)).toList();
    }

    return [];
  }

  /// Create directory if not exists
  Future<void> _createDirectoryIfNotExists(String dirPath) async {
    Directory dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Get total storage usage
  Future<Map<String, int>> getStorageUsage() async {
    Map<String, int> usage = {
      'images': 0,
      'documents': 0,
      'audio': 0,
      'videos': 0,
      'cache': 0,
    };

    // Calculate usage for each directory
    for (String dir in usage.keys) {
      String dirPath = dir == 'cache'
          ? _cacheDirectory!.path
          : '${_appDirectory!.path}/$dir';

      Directory directory = Directory(dirPath);
      if (await directory.exists()) {
        await for (var entity in directory.list(recursive: true)) {
          if (entity is File) {
            usage[dir] = (usage[dir] ?? 0) + await entity.length();
          }
        }
      }
    }

    return usage;
  }
}
