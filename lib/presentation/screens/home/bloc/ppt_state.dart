import 'package:equatable/equatable.dart';
import '../../../../data/models/ppt_response_model.dart';

abstract class PptState extends Equatable {
  const PptState();

  @override
  List<Object?> get props => [];
}

class PptInitial extends PptState {
  const PptInitial();
}

class PptGenerating extends PptState {
  const PptGenerating();
}

class PptGenerated extends PptState {
  final PptResponseModel response;

  const PptGenerated({required this.response});

  @override
  List<Object?> get props => [response];
}

class PptDownloading extends PptState {
  final int progress;

  const PptDownloading({this.progress = 0});

  @override
  List<Object?> get props => [progress];
}

class PptDownloaded extends PptState {
  final String filePath;

  const PptDownloaded({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class PptError extends PptState {
  final String message;

  const PptError({required this.message});

  @override
  List<Object?> get props => [message];
}
