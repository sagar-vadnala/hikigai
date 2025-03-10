import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/custom_loader/custom_loader.dart';
import '../../../shared/error_dialog/error_relod.dart';
import '../../../shared/noDataImage/no_data_available.dart';
import '../../../shared/pagination/pagination.dart';
import '../../../utils/dev.log.dart';
import '../../favourites/state/state.dart';
import '../model/photo.model.dart';
import '../state/state.dart';
import '../widgets/images.dart';

class PhotosScreen extends ConsumerStatefulWidget {
  const PhotosScreen({super.key});

  @override
  ConsumerState<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends ConsumerState<PhotosScreen> {
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    super.dispose();
    // No need to cancel subscription as it's handled in a local function
  }

  // Initialize connectivity checking
  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return;
    }

    if (!mounted) return;

    setState(() {
      _connectivityResult = result;
      _isInitialized = true;
    });
  }

  // Set up ongoing connectivity checking
  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (!mounted) return;

      setState(() {
        _connectivityResult = result;
      });
    });
  }

  bool get isOffline => _connectivityResult == ConnectivityResult.none;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(photosStateNotifierProvider.notifier);
    final paginationProvider = paginationStateNotifierProvider(notifier.fetchMoreData);
    final state = ref.watch(photosStateNotifierProvider);

    // Check if the current state is using cached data
    final isShowingCachedData = state is PhotosStateWithData && state.isFromCache;

    // Wait until connectivity is initialized
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Photo Album'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.fetchData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Show network status bar when offline
          if (isOffline || isShowingCachedData)
            Container(
              color: isOffline ? Colors.red : Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: Text(
                  isOffline ? 'Offline mode - Showing cached data' : 'Showing cached data',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search photos',
                hintText: 'Enter author name or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (value) {
                ref.read(photosStateNotifierProvider.notifier).updateSearchQuery(value);
              },
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: ref.read(paginationProvider.notifier).scrollController(),
              physics: const BouncingScrollPhysics(),
              slivers: [
                _PhotosListContainer(isOffline: isOffline),
                SliverToBoxAdapter(
                  child: PaginationLoadingIndicator(provider: paginationProvider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotosListContainer extends ConsumerWidget {
  final bool isOffline;

  const _PhotosListContainer({required this.isOffline});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photosStateNotifierProvider);

    if (state is PhotosStateLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CustomLoader(),
        ),
      );
    }

    if (state is PhotosStateNoData) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const NoDataAvailableImage(),
              if (isOffline)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'You are offline and no cached photos are available',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (state is PhotosStateError) {
      return SliverFillRemaining(
        child: Center(
          child: ErrorReload(
            errorMessage: isOffline
                ? 'You are offline. Connect to the internet to load new photos.'
                : state.error,
            reloadFunction: ref.read(photosStateNotifierProvider.notifier).fetchData,
          ),
        ),
      );
    }

    if (state is PhotosStateWithData) {
      final filteredPhotos = state.filteredPhotos;

      if (filteredPhotos.isEmpty && state.searchQuery.isNotEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No photos match "${state.searchQuery}"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(photosStateNotifierProvider.notifier).updateSearchQuery('');
                  },
                  child: const Text('Clear Search'),
                ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.all(8.0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.82,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final photo = filteredPhotos[index];
              return PhotoCard(photo: photo);
            },
            childCount: filteredPhotos.length,
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(
      child: Center(
        child: NoDataAvailableImage(),
      ),
    );
  }
}

class PhotoCard extends ConsumerWidget {
  final PhotosData photo;

  const PhotoCard({super.key, required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Watch for changes in the favorites state
    final favorites = ref.watch(favouritesStateNotifierProvider);
    final isFavorite = favorites.contains(photo.id.toString());

    // Add debug log to track favorite status
    Dev.debug('PhotoCard: ID=${photo.id}, isFavorite=$isFavorite');

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(100),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 115,
            width: double.infinity,
            child: ExtendedCachedImage(
              imageUrl: photo.downloadUrl,
              fit: BoxFit.cover,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By ${photo.author}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${photo.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : theme.colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: () {
                        try {
                          Dev.debug('Toggling favorite for ID=${photo.id}, current=${isFavorite}');
                          if (isFavorite) {
                            // If the photo is a favorite, remove it
                            ref.read(favouritesScreenStateNotifierProvider.notifier).remove(photo);
                          } else {
                            // If the photo is not a favorite, add it
                            ref.read(favouritesScreenStateNotifierProvider.notifier).add(photo);
                          }
                        } catch (e) {
                          Dev.error('Error toggling favorite', error: e);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
