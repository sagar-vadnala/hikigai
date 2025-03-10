import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DioAuthTokenInterceptor extends Interceptor {
  const DioAuthTokenInterceptor({
    required this.updateAuthToken,
  });

  final void Function(String) updateAuthToken;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final headers = response.headers;
    final authorizationHeader = headers.map['authorization']?[0];
    if (authorizationHeader != null) {
      updateAuthToken(authorizationHeader);
    }
    super.onResponse(response, handler);
  }
}

class DioInvalidTokenInterceptor extends Interceptor {
  const DioInvalidTokenInterceptor({
    required this.ref,
    required this.removeAuthHeader,
  });

  final ProviderRef ref;
  final Function removeAuthHeader;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
      if (response.data != null && response.data is Map) {
        final responseData = response.data as Map;
        if (responseData.containsKey('code') &&
            responseData['code'] != null &&
            responseData['code'].toString().isNotEmpty) {
          if (responseData['code'] == ApiErrorCodes.invalidToken) {
            fun();
          }
        }
      }
    }
    super.onResponse(response, handler);
  }

  Future<void> fun() async {
    removeAuthHeader();

    /// TODO  - Add the following code to the function after implementing the required classes
    // await ref.read(authStateNotifierProvider.notifier).logout();
    // await ref.read(appRouterProvider).replaceAll(const [LoginRoute()]);
    // await ref.read(appRouterProvider).push(CustomDismissibleDialogRoute(
    //       child: const InvalidTokenErrorDialog(),
    //     ));
  }
}

abstract class ApiErrorCodes {
  static const invalidToken = 'INVALID_TOKEN';
  static const tokenExpired = 'TOKEN_EXPIRED';
  static const unauthorized = 'UNAUTHORIZED';
  static const insufficientPermissions = 'INSUFFICIENT_PERMISSIONS';
  static const internalServerError = 'INTERNAL_SERVER_ERROR';
  static const invalidParameters = 'INVALID_PARAMETERS';
}
