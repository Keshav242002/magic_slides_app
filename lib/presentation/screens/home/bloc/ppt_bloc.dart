import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/ppt_repository.dart';
import 'ppt_event.dart';
import 'ppt_state.dart';

class PptBloc extends Bloc<PptEvent, PptState> {
  final PptRepository _pptRepository;

  PptBloc({required PptRepository pptRepository})
      : _pptRepository = pptRepository,
        super(const PptInitial()) {
    on<GeneratePptEvent>(_onGeneratePpt);
    on<DownloadPptEvent>(_onDownloadPpt);
    on<ResetPptEvent>(_onResetPpt);
  }

  Future<void> _onGeneratePpt(
    GeneratePptEvent event,
    Emitter<PptState> emit,
  ) async {
    emit(const PptGenerating());

    final response = await _pptRepository.generatePpt(event.request);

    if (response.isSuccess && response.data != null) {
      emit(PptGenerated(response: response.data!));
    } else {
      emit(PptError(message: response.message ?? 'Failed to generate presentation'));
    }
  }

  Future<void> _onDownloadPpt(
    DownloadPptEvent event,
    Emitter<PptState> emit,
  ) async {
    emit(const PptDownloading(progress: 0));

    final response = await _pptRepository.downloadFile(
      url: event.url,
      fileName: event.fileName,
      onProgress: (received, total) {
        if (total != -1) {
          final progress = ((received / total) * 100).round();
          emit(PptDownloading(progress: progress));
        }
      },
    );

    if (response.isSuccess && response.data != null) {
      emit(PptDownloaded(filePath: response.data!));
    } else {
      emit(PptError(message: response.message ?? 'Failed to download file'));
    }
  }

  Future<void> _onResetPpt(
    ResetPptEvent event,
    Emitter<PptState> emit,
  ) async {
    emit(const PptInitial());
  }
}
