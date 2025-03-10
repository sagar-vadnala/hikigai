import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/custom_loader/custom_loader.dart';
import '../../shared/error_dialog/error_relod.dart';
import '../../shared/noDataImage/no_data_available.dart';
import '../home/model/photo.model.dart';
import '../home/view/home.dart';
import 'state/state.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Favorite Photos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              Text(
                'Photos you liked',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      body: const _ListContainer(),
    );
  }
}

class _ListContainer extends ConsumerWidget {
  const _ListContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favouritesScreenStateNotifierProvider);

    if (state is FavouritesScreenLoading) {
      return const Center(child: CustomLoader());
    }

    if (state is FavouritesScreenNoData) {
      return const Center(child: NoDataAvailableImage());
    }

    if (state is FavouritesScreenError) {
      return Center(
        child: ErrorReload(
          errorMessage: state.message,
          reloadFunction: ref.read(favouritesScreenStateNotifierProvider.notifier).init,
        ),
      );
    }

    if (state is FavouritesScreenWithData) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: _PhotosGrid(data: state.data),
      );
    }

    return const Center(child: NoDataAvailableImage());
  }
}

class _PhotosGrid extends StatelessWidget {
  const _PhotosGrid({
    required this.data,
  });

  final UnmodifiableSetView<PhotosData> data;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: data.length,
      itemBuilder: (context, i) {
        return PhotoCard(photo: data.elementAt(i));
      },
    );
  }
}
