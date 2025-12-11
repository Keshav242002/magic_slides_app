import 'package:equatable/equatable.dart';

class PptRequestModel extends Equatable {
  final String topic;
  final String? extraInfoSource;
  final String email;
  final String accessId;
  final String? template;
  final String? language;
  final int? slideCount;
  final bool? aiImages;
  final bool? imageForEachSlide;
  final bool? googleImage;
  final bool? googleText;
  final String? model;
  final String? presentationFor;
  final WatermarkModel? watermark;

  const PptRequestModel({
    required this.topic,
    this.extraInfoSource,
    required this.email,
    required this.accessId,
    this.template,
    this.language,
    this.slideCount,
    this.aiImages,
    this.imageForEachSlide,
    this.googleImage,
    this.googleText,
    this.model,
    this.presentationFor,
    this.watermark,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'topic': topic,
      'email': email,
      'accessId': accessId,
    };

    if (extraInfoSource != null) map['extraInfoSource'] = extraInfoSource;
    if (template != null) map['template'] = template;
    if (language != null) map['language'] = language;
    if (slideCount != null) map['slideCount'] = slideCount;
    if (aiImages != null) map['aiImages'] = aiImages;
    if (imageForEachSlide != null) map['imageForEachSlide'] = imageForEachSlide;
    if (googleImage != null) map['googleImage'] = googleImage;
    if (googleText != null) map['googleText'] = googleText;
    if (model != null) map['model'] = model;
    if (presentationFor != null) map['presentationFor'] = presentationFor;
    if (watermark != null) map['watermark'] = watermark!.toJson();

    return map;
  }

  @override
  List<Object?> get props => [
        topic,
        extraInfoSource,
        email,
        accessId,
        template,
        language,
        slideCount,
        aiImages,
        imageForEachSlide,
        googleImage,
        googleText,
        model,
        presentationFor,
        watermark,
      ];
}

class WatermarkModel extends Equatable {
  final String width;
  final String height;
  final String brandURL;
  final String position;

  const WatermarkModel({
    required this.width,
    required this.height,
    required this.brandURL,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'brandURL': brandURL,
      'position': position,
    };
  }

  factory WatermarkModel.fromJson(Map<String, dynamic> json) {
    return WatermarkModel(
      width: json['width'] as String,
      height: json['height'] as String,
      brandURL: json['brandURL'] as String,
      position: json['position'] as String,
    );
  }

  @override
  List<Object?> get props => [width, height, brandURL, position];
}
