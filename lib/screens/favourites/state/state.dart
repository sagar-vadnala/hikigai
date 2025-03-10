import 'dart:collection';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/api/api.dart';
import '../../../utils/dev.log.dart';
import '../../home/model/photo.model.dart';
import 'storage.dart';

part 'state.g.dart';

class FavouritesScreenState {
  const FavouritesScreenState();
}

class FavouritesScreenLoading extends FavouritesScreenState {
  const FavouritesScreenLoading();
}

class FavouritesScreenWithData extends FavouritesScreenState {
  const FavouritesScreenWithData(this.data);
  final UnmodifiableSetView<PhotosData> data;
}

class FavouritesScreenNoData extends FavouritesScreenState {
  const FavouritesScreenNoData();
}

class FavouritesScreenError extends FavouritesScreenState {
  const FavouritesScreenError(this.message);
  final String message;
}

@riverpod
class FavouritesScreenStateNotifier extends _$FavouritesScreenStateNotifier {
  @override
  FavouritesScreenState build() {
    // Start with loading state instead of trying to access state before init
    state = const FavouritesScreenLoading();
    // Call init after a short delay to avoid initialization errors
    Future.microtask(() => init());
    return state;
  }

  Future<void> init() async {
    try {
      state = const FavouritesScreenLoading();
      await ref.read(favouritesStateNotifierProvider.notifier).readData();
      final res = ref.read(favouritesStateNotifierProvider);
      if (res.isEmpty) {
        state = const FavouritesScreenNoData();
      } else {
        await fetchData();
      }
    } catch (e, s) {
      Dev.error('FavouritesScreen init error', error: e, stackTrace: s);
      state = FavouritesScreenError(Utils.renderException(e));
    }
  }

  Future<void> add(PhotosData p) async {
    try {
      await ref.read(favouritesStateNotifierProvider.notifier).add(p.id.toString());

      // Update the state to include the new photo
      if (state is FavouritesScreenWithData) {
        final currentData = (state as FavouritesScreenWithData).data;
        final Set<PhotosData> updatedSet = Set.from(currentData);
        updatedSet.add(p);
        state = FavouritesScreenWithData(UnmodifiableSetView(updatedSet));
      } else {
        // If there's no data yet, create a new set with just this photo
        state = FavouritesScreenWithData(UnmodifiableSetView({p}));
      }

      // Debug log to check addition
      Dev.debug('Added photo to favorites: ID=${p.id}');
    } catch (e, s) {
      Dev.error('Error adding photo to favorites', error: e, stackTrace: s);
    }
  }

  Future<void> remove(PhotosData p) async {
    try {
      await ref.read(favouritesStateNotifierProvider.notifier).remove(p.id.toString());

      if (state is FavouritesScreenWithData) {
        final Set<PhotosData> temp = Set.from((state as FavouritesScreenWithData).data);
        temp.removeWhere((elem) => elem.id.toString() == p.id.toString());

        if (temp.isEmpty) {
          state = const FavouritesScreenNoData();
        } else {
          state = FavouritesScreenWithData(UnmodifiableSetView(temp));
        }

        // Debug log to check removal
        Dev.debug('Removed photo from favorites: ID=${p.id}');
      }
    } catch (e, s) {
      Dev.error('Error removing photo from favorites', error: e, stackTrace: s);
    }
  }

  Future<void> fetchData() async {
    try {
      Dev.debug('Fetching favorite photos...');

      // Get the list of liked photo IDs
      final likedPhotoIds = ref.read(favouritesStateNotifierProvider);

      Dev.debug('Liked photo IDs: $likedPhotoIds');

      if (likedPhotoIds.isEmpty) {
        state = const FavouritesScreenNoData();
        return;
      }

      // Fetch the photos using the liked photo IDs
      final result = await ref.read(apiProvider).fetchPhotos(includes: likedPhotoIds);

      if (!result.success || result.data == null || result.data!.isEmpty) {
        Dev.debug('No favorite photos found or API request failed');
        state = const FavouritesScreenNoData();
      } else {
        // Process the photos
        final processedData = _processRawData(result.data!);
        Dev.debug('Processed favorite photos: ${processedData.length}');

        if (processedData.isEmpty) {
          state = const FavouritesScreenNoData();
        } else {
          state = FavouritesScreenWithData(UnmodifiableSetView(processedData));
        }
      }
    } catch (e, s) {
      Dev.error('Fetch Favorites Photos error', error: e, stackTrace: s);
      if (state is! FavouritesScreenWithData) {
        state = FavouritesScreenError(Utils.renderException(e));
      }
    }
  }

  Set<PhotosData> _processRawData(List<Map<String, dynamic>> dataList) {
    final Set<PhotosData> result = {};

    for (var data in dataList) {
      try {
        final photo = PhotosData.fromMap(data);
        // No need to filter based on IDs - the API should only return favorites
        result.add(photo);
        Dev.debug('Processed favorite photo: ID=${photo.id}, Author=${photo.author}');
      } catch (e, s) {
        Dev.error('Error processing photo data', error: e, stackTrace: s);
      }
    }

    return result;
  }
}

@Riverpod(keepAlive: true)
class FavouritesStateNotifier extends _$FavouritesStateNotifier {
  @override
  Set<String> build() {
    // Start with an empty set and read data asynchronously
    Future.microtask(() => readData());
    return const <String>{};
  }

  Future<void> readData() async {
    try {
      final favorites = await FavouritesLocalStorage.getFavourites();
      Dev.debug('Read favorites from storage: $favorites');
      state = favorites;
    } catch (e, s) {
      Dev.error('Error reading favorites from storage', error: e, stackTrace: s);
    }
  }

  Future<void> add(String p) async {
    try {
      await FavouritesLocalStorage.saveFavourites(p);
      state = {p, ...state};
      Dev.debug('Added ID to favorites: $p, Current state: $state');
    } catch (e, s) {
      Dev.error('Error adding to favorites', error: e, stackTrace: s);
    }
  }

  Future<void> remove(String p) async {
    try {
      await FavouritesLocalStorage.deleteFavourites(p);
      final temp = Set<String>.from(state);
      temp.remove(p);
      state = Set<String>.from(temp);
      Dev.debug('Removed ID from favorites: $p, Current state: $state');
    } catch (e, s) {
      Dev.error('Error removing from favorites', error: e, stackTrace: s);
    }
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
