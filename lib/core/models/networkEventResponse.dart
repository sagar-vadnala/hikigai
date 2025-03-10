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

class NetworkEventResponse<T> {
  final bool success;
  final String? code;
  final String? message;
  final T? data;

  const NetworkEventResponse.failure({
    this.code = 'undefined',
    this.message,
    this.data,
  }) : success = false;

  const NetworkEventResponse.success({
    this.code = 'undefined',
    this.message,
    this.data,
  }) : success = true;
}
