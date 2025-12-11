import 'package:equatable/equatable.dart';

class PptResponseModel extends Equatable {
  final bool success;
  final String? status;
  final PptDataModel? data;
  final String? message;

  const PptResponseModel({
    required this.success,
    this.status,
    this.data,
    this.message,
  });

  factory PptResponseModel.fromJson(Map<String, dynamic> json) {
    return PptResponseModel(
      success: json['success'] as bool? ?? (json['status'] == 'success'),
      status: json['status'] as String?,
      data: json['data'] != null
          ? PptDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status': status,
      'data': data?.toJson(),
      'message': message,
    };
  }

  @override
  List<Object?> get props => [success, status, data, message];
}

class PptDataModel extends Equatable {
  final String url;
  final String? pdfUrl;
  final String? pptId;

  const PptDataModel({
    required this.url,
    this.pdfUrl,
    this.pptId,
  });

  factory PptDataModel.fromJson(Map<String, dynamic> json) {
    return PptDataModel(
      url: json['url'] as String,
      pdfUrl: json['pdfUrl'] as String?,
      pptId: json['pptId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'pdfUrl': pdfUrl,
      'pptId': pptId,
    };
  }

  @override
  List<Object?> get props => [url, pdfUrl, pptId];
}