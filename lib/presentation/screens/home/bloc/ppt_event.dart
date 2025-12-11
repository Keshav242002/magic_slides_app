import 'package:equatable/equatable.dart';
import '../../../../data/models/ppt_request_model.dart';

abstract class PptEvent extends Equatable {
  const PptEvent();

  @override
  List<Object?> get props => [];
}

class GeneratePptEvent extends PptEvent {
  final PptRequestModel request;

  const GeneratePptEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

class DownloadPptEvent extends PptEvent {
  final String url;
  final String fileName;

  const DownloadPptEvent({
    required this.url,
    required this.fileName,
  });

  @override
  List<Object?> get props => [url, fileName];
}

class ResetPptEvent extends PptEvent {
  const ResetPptEvent();
}
