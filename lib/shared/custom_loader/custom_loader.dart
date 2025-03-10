import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoader extends ConsumerWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SpinKitWave(
      color: Theme.of(context).primaryColor,
      size: 40,
    );
  }
}
