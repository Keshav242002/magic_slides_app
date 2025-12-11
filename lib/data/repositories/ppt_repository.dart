import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/network/api_helper.dart';
import '../../core/network/api_response.dart';
import '../../core/constants/api_constants.dart';
import '../models/ppt_request_model.dart';
import '../models/ppt_response_model.dart';

class PptRepository {
  final ApiHelper _apiHelper = ApiHelper();

  Future<ApiResponse<PptResponseModel>> generatePpt(
      PptRequestModel request,
      ) async {
    return await _apiHelper.post<PptResponseModel>(
      ApiConstants.pptFromTopic,
      data: request.toJson(),
      parser: (data) => PptResponseModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<String>> downloadFile({
    required String url,
    required String fileName,
    Function(int, int)? onProgress,
  }) async {
    try {
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';

      return await _apiHelper.downloadFile(
        url: url,
        savePath: filePath,
        onReceiveProgress: onProgress,
      );
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final magicSlidesDir = Directory('${directory.path}/MagicSlides');
        if (!await magicSlidesDir.exists()) {
          await magicSlidesDir.create(recursive: true);
        }
        return magicSlidesDir;
      }
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  String getFileExtension(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    if (path.endsWith('.pptx')) return '.pptx';
    if (path.endsWith('.pdf')) return '.pdf';
    if (path.endsWith('.ppt')) return '.ppt';

    return '.pptx';
  }
}