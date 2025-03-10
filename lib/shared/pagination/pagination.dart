import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../custom_loader/custom_loader.dart';

part 'pagination.g.dart';

enum PaginationActionResponse { failed, lastData, noDataAvailable, success }

@Riverpod()
class PaginationStateNotifier extends _$PaginationStateNotifier {
  @override
  PaginationState build(
    Future<PaginationActionResponse> Function(int) fetchMoreData,
  ) {
    _scrollController.addListener(_scrollListener);
    ref.onDispose(() {
      _scrollController.removeListener(_scrollListener);
    });
    return PaginationState.ideal;
  }

  /// Page number
  int _page = 2;

  final ScrollController _scrollController = ScrollController();

  ScrollController scrollController() => _scrollController;

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _getMoreData();
    }
  }

  Future<void> _getMoreData() async {
    if (state == PaginationState.lastData || state == PaginationState.noData) {
      return;
    }
    if (state != PaginationState.loading) {
      state = PaginationState.loading;

      // Fetch more data
      final result = await fetchMoreData(_page);

      if (result == PaginationActionResponse.failed) {
        state = PaginationState.failed;
      } else if (result == PaginationActionResponse.lastData) {
        state = PaginationState.lastData;
      } else if (result == PaginationActionResponse.noDataAvailable) {
        state = PaginationState.noData;
      } else {
        // If the fetch action was successful
        state = PaginationState.ideal;
        _page++;
      }
    }
  }
}

enum PaginationState {
  ideal,
  loading,
  failed,
  noData,
  lastData,
}

class PaginationLoadingIndicator extends ConsumerWidget {
  const PaginationLoadingIndicator({
    super.key,
    required this.provider,
  });

  final ProviderListenable<PaginationState> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);

    Widget widget = const SizedBox();
    double height = 200;

    if (state == PaginationState.lastData || state == PaginationState.noData) {
      widget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Text(
            // I10n.of(context).endOfList,
            "End of list",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
      height = 100;
    }

    if (state == PaginationState.loading) {
      widget = const CustomLoader();
      height = 100;
    }

    return SizedBox(height: height, child: widget);
  }
}
