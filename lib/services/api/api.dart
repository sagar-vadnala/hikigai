import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../caching/cache.dart';
import '../../constants/config.dart';
import '../../core/models/networkEventResponse.dart';
import '../../screens/home/model/photo.model.dart';
import '../../utils/api_utils.dart';
import '../../utils/dev.log.dart';
import 'interceptors.dart';

part 'api.g.dart';

@Riverpod(keepAlive: true, dependencies: [dio])
Api api(ApiRef ref) {
  final dio = ref.watch(dioProvider);
  return Api(dio);
}

class Api {
  Api(this.dio);

  final Dio dio;
  final Connectivity _connectivity = Connectivity();

  Future<NetworkEventResponse<List<Map<String, dynamic>>>> fetchPhotos({
    int page = 1,
    Set<String>? includes,
  }) async {
    try {
      // Check connectivity first
      final connectivityResult = await _connectivity.checkConnectivity();
      final bool isOffline = connectivityResult == ConnectivityResult.none;

      if (includes != null && includes.isNotEmpty) {
        // For favorites, try to fetch from cache first
        return await _fetchFavoritePhotos(includes, isOffline);
      } else {
        // For regular list, try to fetch from cache if offline or cache is valid
        return await _fetchPagedPhotos(page, isOffline);
      }
    } catch (e, s) {
      Dev.error('Exception Api - Fetch photos', error: e, stackTrace: s);
      return NetworkEventResponse.failure(message: ApiUtils.renderException(e));
    }
  }

  Future<NetworkEventResponse<List<Map<String, dynamic>>>> _fetchPagedPhotos(
      int page, bool isOffline) async {
    try {
      // Check if cache is valid for this page
      final isCacheValid = await PhotoCacheService.isCacheValid(page);

      // If we're offline or cache is valid, get data from cache
      if (isOffline || isCacheValid) {
        Dev.debug('Using cached photos for page $page${isOffline ? " (offline)" : ""}');
        final cachedPhotos = await PhotoCacheService.getCachedPhotos(page);

        if (cachedPhotos.isNotEmpty) {
          // Convert to map format expected by the app
          final List<Map<String, dynamic>> result =
              cachedPhotos.map((photo) => photo.toMap()).toList();
          return NetworkEventResponse.success(data: result);
        }

        // If we're offline and have no cache, return an error
        if (isOffline) {
          return NetworkEventResponse.failure(
            message: 'No internet connection and no cached data available',
          );
        }
      }

      // Fetch from network if online and cache is invalid
      Dev.debug('Fetching photos from network for page $page');

      try {
        // Handle HTTPS issue in release mode by using a specific URL format
        final response = await dio.get(
          '/v2/list',
          queryParameters: {
            'page': page,
            'limit': Config.itemsPerPage,
          },
          options: Options(
            // Force content type for some APIs
            headers: {
              'Accept': 'application/json',
            },
            // Longer timeout for production environment
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        if (response.statusCode != 200) {
          Dev.error('API returned non-200 status: ${response.statusCode}');
          // Try backup strategy - direct URL construction
          final backupResponse = await dio.get(
            'https://picsum.photos/v2/list?page=$page&limit=${Config.itemsPerPage}',
          );

          if (backupResponse.statusCode == 200 && backupResponse.data != null) {
            final responseData = List<Map<String, dynamic>>.from(backupResponse.data);
            // Cache the results
            _cachePagedPhotos(responseData, page);
            return NetworkEventResponse.success(data: responseData);
          } else {
            throw Exception('Failed to fetch photos with status: ${backupResponse.statusCode}');
          }
        }

        if (response.data == null) {
          throw Exception('API returned null data');
        }

        final responseData = List<Map<String, dynamic>>.from(response.data);

        // Cache the results
        _cachePagedPhotos(responseData, page);

        return NetworkEventResponse.success(data: responseData);
      } on DioException catch (e) {
        Dev.error('Dio exception in release mode: ${e.message}', error: e);

        // Try direct URL as a fallback
        try {
          final fallbackResponse = await Dio().get(
            'https://picsum.photos/v2/list?page=$page&limit=${Config.itemsPerPage}',
          );

          if (fallbackResponse.statusCode == 200 && fallbackResponse.data != null) {
            final responseData = List<Map<String, dynamic>>.from(fallbackResponse.data);
            // Cache the results
            _cachePagedPhotos(responseData, page);
            return NetworkEventResponse.success(data: responseData);
          }
        } catch (fallbackError) {
          Dev.error('Fallback request also failed', error: fallbackError);
        }

        throw e; // Re-throw so it can be caught by the outer catch block
      }
    } on DioException catch (e, s) {
      Dev.error('DioException Api - Fetch photos', error: e, stackTrace: s);
      return NetworkEventResponse.failure(message: ApiUtils.handleDioException(e)['error']);
    } catch (e, s) {
      Dev.error('Exception in _fetchPagedPhotos', error: e, stackTrace: s);
      return NetworkEventResponse.failure(message: ApiUtils.renderException(e));
    }
  }

  Future<void> _cachePagedPhotos(List<Map<String, dynamic>> data, int page) async {
    try {
      final List<PhotosData> photos = data.map((item) => PhotosData.fromMap(item)).toList();

      await PhotoCacheService.cachePhotos(photos, page);
      await PhotoCacheService.storePagePhotoMapping(page, photos);
    } catch (e) {
      Dev.error('Error caching paged photos', error: e);
    }
  }

  Future<NetworkEventResponse<List<Map<String, dynamic>>>> _fetchFavoritePhotos(
      Set<String> includes, bool isOffline) async {
    try {
      List<Map<String, dynamic>> results = [];
      List<String> missingIds = [];

      // Try to get photos from cache first
      for (String id in includes) {
        final cachedPhoto = await PhotoCacheService.getSinglePhoto(id);

        if (cachedPhoto != null) {
          results.add(cachedPhoto.toMap());
        } else {
          missingIds.add(id);
        }
      }

      // If offline, return what we have from cache
      if (isOffline) {
        Dev.debug('Offline mode: Retrieved ${results.length} favorites from cache');
        if (results.isEmpty) {
          return NetworkEventResponse.failure(
            message: 'No internet connection and no cached favorites available',
          );
        }
        return NetworkEventResponse.success(data: results);
      }

      // If online, fetch any missing photos
      if (missingIds.isNotEmpty) {
        Dev.debug('Fetching ${missingIds.length} missing favorite photos from network');

        for (String id in missingIds) {
          try {
            final response = await dio.get('/id/$id/info');
            if (response.statusCode == 200 && response.data != null) {
              results.add(response.data);

              // Cache the individual photo
              final photo = PhotosData.fromMap(response.data);
              await PhotoCacheService.cacheSinglePhoto(photo);
            }
          } catch (e) {
            Dev.error('Error fetching favorite photo by ID: $id', error: e);
            // Continue with other IDs even if one fails
          }
        }
      }

      return NetworkEventResponse.success(data: results);
    } on DioException catch (e, s) {
      Dev.error('DioException Api - Fetch favorite photos', error: e, stackTrace: s);
      return NetworkEventResponse.failure(message: ApiUtils.handleDioException(e)['error']);
    } catch (e, s) {
      Dev.error('Exception in _fetchFavoritePhotos', error: e, stackTrace: s);
      return NetworkEventResponse.failure(message: ApiUtils.renderException(e));
    }
  }
}

@Riverpod(keepAlive: true, dependencies: [])
Dio dio(DioRef ref) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: Config.apiBaseUrl,
      connectTimeout: Config.connectTimeout,
      receiveTimeout: Config.receiveTimeout,
      validateStatus: (status) {
        return status != null && status >= 200 && status < 500;
      },
    ),
  );

  // Enable logging in debug mode and optionally in release mode
  if (kDebugMode || Config.enableDebugInRelease) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  // Interceptors -----------------------------
  dio.interceptors.add(
    DioAuthTokenInterceptor(
      updateAuthToken: (updatedToken) {
        Dev.debug('Updating Auth Token from dio response interceptor');
        dio.options.headers = {
          ...dio.options.headers,
          HttpHeaders.authorizationHeader: updatedToken,
        };
      },
    ),
  );

  void removeAuthHeader() {
    Dev.debug('Removing Auth Token from dio response interceptor');
    dio.options.headers.remove(HttpHeaders.authorizationHeader);
  }

  dio.interceptors.add(DioInvalidTokenInterceptor(
    ref: ref,
    removeAuthHeader: removeAuthHeader,
  ));

  // Add caching interceptor
  dio.interceptors.add(CacheInterceptor());

  return dio;
}

/// Cache interceptor for Dio to handle caching responses
class CacheInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Can add custom response handling here if needed
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      Dev.debug('Network timeout, will try to use cached data');
    }
    super.onError(err, handler);
  }
}
