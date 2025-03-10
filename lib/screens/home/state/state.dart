import 'dart:collection';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../caching/cache.dart';
import '../../../constants/config.dart';
import '../../../services/api/api.dart';
import '../../../shared/pagination/pagination.dart';
import '../../../utils/dev.log.dart';
import '../model/photo.model.dart';

part 'state.g.dart';

@immutable
class PhotosState {
  const PhotosState();
}

class PhotosStateLoading extends PhotosState {
  const PhotosStateLoading();
}

class PhotosStateWithData extends PhotosState {
  final UnmodifiableListView<PhotosData> photos;
  final String searchQuery;
  final bool isFromCache;

  const PhotosStateWithData(
    this.photos, {
    this.searchQuery = '',
    this.isFromCache = false,
  });

  PhotosStateWithData copyWith({
    UnmodifiableListView<PhotosData>? photos,
    String? searchQuery,
    bool? isFromCache,
  }) {
    return PhotosStateWithData(
      photos ?? this.photos,
      searchQuery: searchQuery ?? this.searchQuery,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  UnmodifiableListView<PhotosData> get filteredPhotos {
    if (searchQuery.isEmpty) return photos;

    final searchLower = searchQuery.toLowerCase();
    return UnmodifiableListView(photos
        .where((photo) =>
            photo.author.toLowerCase().contains(searchLower) ||
            photo.id.toString().contains(searchLower))
        .toList());
  }
}

class PhotosStateError extends PhotosState {
  final String error;
  const PhotosStateError(this.error);
}

class PhotosStateNoData extends PhotosState {
  const PhotosStateNoData();
}

@Riverpod(dependencies: [api])
class PhotosStateNotifier extends _$PhotosStateNotifier {
  @override
  PhotosState build() {
    // Start with loading state instead of calling fetchData directly
    state = const PhotosStateLoading();
    // Call fetchData after a short delay to avoid the initialization error
    Future.microtask(() => fetchData());
    return state;
  }

  Future<void> fetchData() async {
    // Function Log
    Dev.debugFunction(
      functionName: 'fetchPhotos',
      className: 'PhotosStateNotifier',
      fileName: '/screens/home/state/state.dart',
      start: false,
    );

    try {
      // Preserve search query if it exists
      String searchQuery = '';
      if (state is PhotosStateWithData) {
        searchQuery = (state as PhotosStateWithData).searchQuery;
      }

      state = const PhotosStateLoading();

      // Check if we're offline using connectivity service
      bool isOffline = false;
      try {
        final connectivityService = await Connectivity().checkConnectivity();
        isOffline = connectivityService == ConnectivityResult.none;
      } catch (e) {
        Dev.error('Error checking connectivity', error: e);
      }

      // First try to get cached data regardless of network status
      final cachedPhotos = await PhotoCacheService.getCachedPhotos(1);
      Dev.debug('Found ${cachedPhotos.length} cached photos');

      if (isOffline) {
        // If offline and we have cached data, use it
        if (cachedPhotos.isNotEmpty) {
          Dev.debug('Using cached data while offline');
          state = PhotosStateWithData(
            UnmodifiableListView(cachedPhotos),
            searchQuery: searchQuery,
            isFromCache: true,
          );
          return;
        } else {
          // If offline and no cache, show error
          state = const PhotosStateError('No internet connection and no cached data available');
          return;
        }
      }

      // If online, try to get fresh data from the network
      final result = await _getDataFromBackend(1);

      if (result.isEmpty) {
        // If no data from network but we have cache, use the cache
        if (cachedPhotos.isNotEmpty) {
          Dev.debug('No data from API but using cached data');
          state = PhotosStateWithData(
            UnmodifiableListView(cachedPhotos),
            searchQuery: searchQuery,
            isFromCache: true,
          );
        } else {
          state = const PhotosStateNoData();
        }
      } else {
        final processedData = _processRawData(result);
        state = PhotosStateWithData(
          UnmodifiableListView(processedData),
          searchQuery: searchQuery,
          isFromCache: false,
        );

        // Cache the new data
        await PhotoCacheService.cachePhotos(processedData, 1);
        await PhotoCacheService.storePagePhotoMapping(1, processedData);
      }
    } catch (e, s) {
      Dev.error(
        'Fetch Photos error',
        error: e,
        stackTrace: s,
      );

      // Try to get cached data on error
      final cachedPhotos = await PhotoCacheService.getCachedPhotos(1);
      if (cachedPhotos.isNotEmpty) {
        Dev.debug('Error fetching data but using cached data');
        state = PhotosStateWithData(
          UnmodifiableListView(cachedPhotos),
          isFromCache: true,
        );
      } else if (state is! PhotosStateWithData) {
        state = PhotosStateError(Utils.renderException(e));
      }
    }
  }

  // Add a new method to update search query
  void updateSearchQuery(String query) {
    if (state is PhotosStateWithData) {
      final currentState = state as PhotosStateWithData;
      state = currentState.copyWith(searchQuery: query);
    }
  }

  Future<PaginationActionResponse> fetchMoreData(int page) async {
    if (state is PhotosStateError) {
      return PaginationActionResponse.failed;
    }

    if (state is PhotosStateWithData &&
        (state as PhotosStateWithData).photos.length < Config.itemsPerPage) {
      return PaginationActionResponse.lastData;
    }

    // Function Log
    Dev.debugFunction(
      functionName: 'fetchMorePhotos',
      className: 'PhotosStateNotifier',
      fileName: '/screens/home/state/state.dart',
      start: false,
    );

    try {
      // Check if we're offline
      bool isOffline = false;
      try {
        final connectivityService = await Connectivity().checkConnectivity();
        isOffline = connectivityService == ConnectivityResult.none;
      } catch (e) {
        Dev.error('Error checking connectivity', error: e);
      }

      // Try to get cached data for this page first
      final cachedPhotos = await PhotoCacheService.getCachedPhotos(page);

      if (isOffline) {
        // If offline, only use cache
        if (cachedPhotos.isNotEmpty) {
          if (state is PhotosStateWithData) {
            final currentState = state as PhotosStateWithData;
            final Set<PhotosData> newSet = currentState.photos.toSet();
            newSet.addAll(cachedPhotos);
            state = PhotosStateWithData(
              UnmodifiableListView(newSet.toList()),
              searchQuery: currentState.searchQuery,
              isFromCache: true,
            );
            return PaginationActionResponse.success;
          }
        }
        return PaginationActionResponse.noDataAvailable;
      }

      // If online, try to get fresh data
      final result = await _getDataFromBackend(page);

      // Function Log
      Dev.debugFunction(
        functionName: 'fetchMorePhotos',
        className: 'PhotosStateNotifier',
        fileName: '/screens/home/state/state.dart',
        start: false,
      );

      if (result.isEmpty) {
        // If no new data but we have cache, use the cache
        if (cachedPhotos.isNotEmpty && state is PhotosStateWithData) {
          final currentState = state as PhotosStateWithData;
          final Set<PhotosData> newSet = currentState.photos.toSet();
          newSet.addAll(cachedPhotos);
          state = PhotosStateWithData(
            UnmodifiableListView(newSet.toList()),
            searchQuery: currentState.searchQuery,
            isFromCache: true,
          );
          return PaginationActionResponse.success;
        }

        if (state is! PhotosStateWithData) {
          state = const PhotosStateNoData();
        }
        return PaginationActionResponse.noDataAvailable;
      } else {
        // Process the new data
        final processedData = _processRawData(result);

        // Cache the new data
        await PhotoCacheService.cachePhotos(processedData, page);
        await PhotoCacheService.storePagePhotoMapping(page, processedData);

        // Update the state
        if (state is PhotosStateWithData) {
          final currentState = state as PhotosStateWithData;
          final Set<PhotosData> newSet = currentState.photos.toSet();
          newSet.addAll(processedData);
          state = PhotosStateWithData(
            UnmodifiableListView(newSet.toList()),
            searchQuery: currentState.searchQuery,
            isFromCache: false,
          );
        } else {
          state = PhotosStateWithData(
            UnmodifiableListView(processedData),
            isFromCache: false,
          );
        }

        if (result.length < Config.itemsPerPage) {
          // If result is less than the requested length, then
          // this is the last lot of data.
          return PaginationActionResponse.lastData;
        } else {
          return PaginationActionResponse.success;
        }
      }
    } catch (e, s) {
      Dev.error(
        'Fetch more data error',
        error: e,
        stackTrace: s,
      );

      // Try to get cached data on error
      final cachedPhotos = await PhotoCacheService.getCachedPhotos(page);
      if (cachedPhotos.isNotEmpty && state is PhotosStateWithData) {
        final currentState = state as PhotosStateWithData;
        final Set<PhotosData> newSet = currentState.photos.toSet();
        newSet.addAll(cachedPhotos);
        state = PhotosStateWithData(
          UnmodifiableListView(newSet.toList()),
          searchQuery: currentState.searchQuery,
          isFromCache: true,
        );
        return PaginationActionResponse.success;
      }

      return PaginationActionResponse.failed;
    }
  }

  Future<List<Map<String, dynamic>>> _getDataFromBackend(int page) async {
    final result = await ref.read(apiProvider).fetchPhotos(
          page: page,
        );

    if (!result.success) {
      throw Exception(result.message);
    }

    if (result.data == null || result.data!.isEmpty) {
      return const [];
    }

    return result.data!;
  }

  @protected
  List<PhotosData> _processRawData(List<Map<String, dynamic>> dataList) {
    // Function Log
    Dev.debugFunction(
      functionName: 'processRawData',
      className: 'PhotosStateNotifier',
      fileName: '/screens/home/state/state.dart',
      start: false,
    );

    final List<PhotosData> result = [];
    if (dataList.isNotEmpty) {
      for (var data in dataList) {
        try {
          final obj = PhotosData.fromMap(data);
          result.add(obj);
        } catch (e) {
          Dev.error('Error processing photo data', error: e);
        }
      }
    }

    // Function Log
    Dev.debugFunction(
      functionName: 'processRawData',
      className: 'PhotosStateNotifier',
      fileName: '/screens/home/state/state.dart',
      start: false,
    );

    return result;
  }
}

class Utils {
  static String renderException(dynamic e) {
    if (e == null || e is! Exception) {
      return '';
    }
    return e.toString().replaceAll(RegExp(r'(Exception):?'), '').trim();
  }
}
