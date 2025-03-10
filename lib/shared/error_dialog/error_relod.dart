import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import 'animated_button.dart';

class ErrorReload extends StatelessWidget {
  const ErrorReload({
    super.key,
    required this.errorMessage,
    required this.reloadFunction,
  });

  final String errorMessage;
  final void Function() reloadFunction;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 100,
      maxWidth: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                isBlank(errorMessage) ? 'Something went wrong!' : errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              AnimButton(
                onTap: reloadFunction,
                child: CustomButtonStyle(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Reload'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorReloadWithIcon extends StatelessWidget {
  const ErrorReloadWithIcon({
    super.key,
    required this.errorMessage,
    required this.reloadFunction,
  });

  final String errorMessage;
  final void Function() reloadFunction;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Flexible(
            child: FittedBox(
              child: Icon(
                Icons.error_outline_rounded,
                size: 100,
                color: Color(0xFFEF5350),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isBlank(errorMessage) ? 'Something went wrong!' : errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimButton(
            onTap: reloadFunction,
            child: CustomButtonStyle(
              color: Theme.of(context).disabledColor.withAlpha(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Reload'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
