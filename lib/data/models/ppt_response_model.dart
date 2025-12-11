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
    final rawData = json['data'];

    return PptResponseModel(
      success: json['success'] as bool? ?? (json['status'] == 'success'),
      status: json['status'] as String?,
      data: (rawData is Map<String, dynamic> && rawData.containsKey('url'))
          ? PptDataModel.fromJson(rawData)
          : null,
      message: (rawData is Map<String, dynamic> && rawData['message'] is String)
          ? rawData['message'] as String
          : json['message'] as String?,
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