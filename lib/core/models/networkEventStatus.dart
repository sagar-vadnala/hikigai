//  Copyright (c) 2024 Aniket Malik [aniketmalikwork@gmail.com]
//  All Rights Reserved.
//
//  NOTICE: All information contained herein is, and remains the
//  property of Aniket Malik. The intellectual and technical concepts
//  contained herein are proprietary to Aniket Malik and are protected
//  by trade secret or copyright law.
//
//  Dissemination of this information or reproduction of this material
//  is strictly forbidden unless prior written permission is obtained from
//  Aniket Malik.

part of 'networkEventStatus.dart';

enum NetworkEventStatusType {
  loading,
  failed,
  successful,
}

class NetworkEventStatus<T> {
  /// The response got from the network event.
  final T? response;

  /// The type of the network event status
  final NetworkEventStatusType type;

  const NetworkEventStatus({
    this.response,
    required this.type,
  });

  const NetworkEventStatus.loading({
    this.response,
    this.type = NetworkEventStatusType.loading,
  });

  const NetworkEventStatus.failed({
    this.response,
    this.type = NetworkEventStatusType.failed,
  });

  const NetworkEventStatus.success({
    required this.response,
    this.type = NetworkEventStatusType.successful,
  });
}
