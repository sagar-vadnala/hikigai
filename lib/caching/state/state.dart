import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../utils/dev.log.dart';

part 'state.g.dart';

enum NetworkStatus { online, offline }

@Riverpod(keepAlive: true)
class NetworkConnectivity extends _$NetworkConnectivity {
  final Connectivity _connectivity = Connectivity();

  @override
  NetworkStatus build() {
    _setupConnectivityListener();
    return NetworkStatus.online; // Default to online initially
  }

  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        if (state != NetworkStatus.offline) {
          Dev.debug('Network changed to OFFLINE');
          state = NetworkStatus.offline;
        }
      } else {
        if (state != NetworkStatus.online) {
          Dev.debug('Network changed to ONLINE');
          state = NetworkStatus.online;
        }
      }
    });

    // Check current connectivity right away
    _checkCurrentConnectivity();
  }

  Future<void> _checkCurrentConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      state = NetworkStatus.offline;
    } else {
      state = NetworkStatus.online;
    }
    Dev.debug('Initial network status: ${state.name}');
  }

  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

// Create a widget to show network status when appropriate
class NetworkStatusBar extends ConsumerWidget {
  const NetworkStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkConnectivityProvider);

    if (networkStatus == NetworkStatus.online) {
      return const SizedBox.shrink(); // Don't show anything when online
    }

    return Container(
      color: Colors.red,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: const Center(
        child: Text(
          'No internet connection - Showing cached data',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
