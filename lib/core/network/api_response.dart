import 'package:equatable/equatable.dart';

class ApiResponse<T> extends Equatable {
  final T? data;
  final String? message;
  final bool isSuccess;
  final int? statusCode;

  const ApiResponse({
    this.data,
    this.message,
    required this.isSuccess,
    this.statusCode,
  });

  factory ApiResponse.success({T? data, String? message, int? statusCode}) {
    return ApiResponse(
      data: data,
      message: message,
      isSuccess: true,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({String? message, int? statusCode}) {
    return ApiResponse(
      message: message ?? 'Something went wrong',
      isSuccess: false,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.networkError() {
    return const ApiResponse(
      message: 'No internet connection. Please check your network.',
      isSuccess: false,
    );
  }

  factory ApiResponse.timeout() {
    return const ApiResponse(
      message: 'Request timeout. Please try again.',
      isSuccess: false,
    );
  }

  @override
  List<Object?> get props => [data, message, isSuccess, statusCode];
}
