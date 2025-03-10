import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../utils/dev.log.dart';
import '../../screens/home/model/photo.model.dart';

abstract class PhotoCacheService {
  static const String photosBoxName = 'photosCache';
  static const String photosMetadataKey = 'photosMetadata';
  static const int cacheDurationHours = 24; // Cache validity in hours

  /// Initialize the cache
  static Future<void> init() async {
    if (!Hive.isBoxOpen(photosBoxName)) {
      await Hive.openBox(photosBoxName);
    }
  }

  /// Close the cache box
  static Future<void> closeBox() async {
    if (Hive.isBoxOpen(photosBoxName)) {
      await Hive.box(photosBoxName).close();
    }
  }

  /// Clear all cached photos
  static Future<void> clearCache() async {
    try {
      final box = await _getBox();
      await box.clear();
      Dev.debug('Photo cache cleared');
    } catch (e) {
      Dev.error('Error clearing photo cache', error: e);
    }
  }

  /// Get the photos cache box
  static Future<Box> _getBox() async {
    if (Hive.isBoxOpen(photosBoxName)) {
      return Hive.box(photosBoxName);
    } else {
      return await Hive.openBox(photosBoxName);
    }
  }

  /// Save photos to cache with page information
  static Future<void> cachePhotos(List<PhotosData> photos, int page) async {
    try {
      final box = await _getBox();

      // Get existing metadata or create new
      final metadataJson = box.get(photosMetadataKey);
      final Map<String, dynamic> metadata = metadataJson != null
          ? json.decode(metadataJson)
          : {'lastUpdated': DateTime.now().toIso8601String(), 'pages': {}};

      // Update metadata
      metadata['lastUpdated'] = DateTime.now().toIso8601String();
      (metadata['pages'] as Map<String, dynamic>)[page.toString()] =
          DateTime.now().toIso8601String();

      // Save metadata
      await box.put(photosMetadataKey, json.encode(metadata));

      // Save each photo with its ID as key
      for (final photo in photos) {
        await box.put(photo.id.toString(), photo.toJson());
      }

      Dev.debug('Cached ${photos.length} photos for page $page');
    } catch (e) {
      Dev.error('Error caching photos', error: e);
    }
  }

  /// Check if cache for a specific page is valid
  static Future<bool> isCacheValid(int page) async {
    try {
      final box = await _getBox();
      final metadataJson = box.get(photosMetadataKey);

      if (metadataJson == null) return false;

      final metadata = json.decode(metadataJson);
      final pages = metadata['pages'] as Map<String, dynamic>;

      if (!pages.containsKey(page.toString())) return false;

      final pageTimestamp = DateTime.parse(pages[page.toString()]);
      final now = DateTime.now();

      // Check if cache is still valid (within cache duration)
      return now.difference(pageTimestamp).inHours < cacheDurationHours;
    } catch (e) {
      Dev.error('Error checking cache validity', error: e);
      return false;
    }
  }

  /// Get cached photos for a specific page
  static Future<List<PhotosData>> getCachedPhotos(int page) async {
    try {
      final box = await _getBox();
      final metadataJson = box.get(photosMetadataKey);

      if (metadataJson == null) return [];

      final metadata = json.decode(metadataJson);
      final pages = metadata['pages'] as Map<String, dynamic>;

      if (!pages.containsKey(page.toString())) return [];

      // Get all photos from cache
      final List<PhotosData> cachedPhotos = [];

      // We need to retrieve the photos that belong to this page
      // For this, we'll use another method to store page-photo mappings
      final pageKey = 'page_$page';
      final photoIdsJson = box.get(pageKey);

      if (photoIdsJson == null) return [];

      final photoIds = json.decode(photoIdsJson) as List;

      for (final id in photoIds) {
        final photoJson = box.get(id.toString());
        if (photoJson != null) {
          cachedPhotos.add(PhotosData.fromJson(photoJson));
        }
      }

      Dev.debug('Retrieved ${cachedPhotos.length} cached photos for page $page');
      return cachedPhotos;
    } catch (e) {
      Dev.error('Error getting cached photos', error: e);
      return [];
    }
  }

  /// Store mapping between page and photo IDs
  static Future<void> storePagePhotoMapping(int page, List<PhotosData> photos) async {
    try {
      final box = await _getBox();
      final photoIds = photos.map((p) => p.id.toString()).toList();
      await box.put('page_$page', json.encode(photoIds));
    } catch (e) {
      Dev.error('Error storing page-photo mapping', error: e);
    }
  }

  /// Cache a single photo (useful for favorites)
  static Future<void> cacheSinglePhoto(PhotosData photo) async {
    try {
      final box = await _getBox();
      await box.put(photo.id.toString(), photo.toJson());
      Dev.debug('Cached single photo: ID=${photo.id}');
    } catch (e) {
      Dev.error('Error caching single photo', error: e);
    }
  }

  /// Get a single photo from cache
  static Future<PhotosData?> getSinglePhoto(String id) async {
    try {
      final box = await _getBox();
      final photoJson = box.get(id);

      if (photoJson == null) return null;

      return PhotosData.fromJson(photoJson);
    } catch (e) {
      Dev.error('Error getting single photo from cache', error: e);
      return null;
    }
  }
}
