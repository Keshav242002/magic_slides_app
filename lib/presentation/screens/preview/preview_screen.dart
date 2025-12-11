
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_file/open_file.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/repositories/ppt_repository.dart';
import '../../widgets/custom_button.dart';
import '../home/bloc/ppt_bloc.dart';
import '../home/bloc/ppt_event.dart';
import '../home/bloc/ppt_state.dart';

class PreviewScreen extends StatefulWidget {
  final String pptUrl;      
  final String? pdfUrl;     

  const PreviewScreen({
    super.key,
    required this.pptUrl,
    this.pdfUrl,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isPdfLoading = true;
  String? _pdfError;

  void _handleDownload(BuildContext context) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final repository = context.read<PptRepository>();
    final extension = repository.getFileExtension(widget.pptUrl);
    final fileName = 'MagicSlides_$timestamp$extension';

    context.read<PptBloc>().add(
      DownloadPptEvent(
        url: widget.pptUrl,  
        fileName: fileName,
      ),
    );
  }

  void _openFile(String filePath) async {
    final result = await OpenFile.open(filePath);

    if (result.type != ResultType.done) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Could not open file: ${result.message}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPdfPreview = widget.pdfUrl != null && widget.pdfUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              context.read<PptBloc>().add(const ResetPptEvent());
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            tooltip: 'Home',
          ),
        ],
      ),
      body: BlocConsumer<PptBloc, PptState>(
        listener: (context, state) {
          if (state is PptError) {
            SnackbarUtils.showError(context, state.message);
          } else if (state is PptDownloaded) {
            SnackbarUtils.showSuccess(
              context,
              'PowerPoint downloaded successfully!',
            );
            _openFile(state.filePath);
          }
        },
        builder: (context, state) {
          final isDownloading = state is PptDownloading;

          return Column(
            children: [
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: theme.primaryColor.withValues(alpha:0.1),
              //     border: Border(
              //       bottom: BorderSide(
              //         color: theme.dividerColor,
              //         width: 1,
              //       ),
              //     ),
              //   ),
              //   child: Column(
              //     children: [
              //       Icon(
              //         Icons.check_circle_outline,
              //         size: 56,
              //         color: theme.primaryColor,
              //       ),
              //       const SizedBox(height: 12),
              //       Text(
              //         'Presentation Generated Successfully!',
              //         style: theme.textTheme.headlineMedium,
              //         textAlign: TextAlign.center,
              //       ),
              //       const SizedBox(height: 8),
              //       if (hasPdfPreview)
              //         Text(
              //           'Preview your presentation below',
              //           style: theme.textTheme.bodyMedium?.copyWith(
              //             color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.7),
              //           ),
              //           textAlign: TextAlign.center,
              //         ),
              //     ],
              //   ),
              // ),

              Expanded(
                child: hasPdfPreview
                    ? _buildPdfPreview(theme)
                    : _buildNoPreviewPlaceholder(theme),
              ),

              if (isDownloading)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.file_download,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Downloading PowerPoint...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(state).progress}%',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (state).progress / 100,
                          minHeight: 8,
                          backgroundColor: theme.primaryColor.withValues(alpha:0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomButton(
                      text: 'Download PowerPoint',
                      onPressed: isDownloading ? null : () => _handleDownload(context),
                      isLoading: isDownloading,
                      icon: Icons.download_rounded,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Generate Another',
                      onPressed: isDownloading
                          ? null
                          : () {
                        context.read<PptBloc>().add(const ResetPptEvent());
                        Navigator.of(context).pop();
                      },
                      isOutlined: true,
                      icon: Icons.refresh_rounded,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPdfPreview(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: theme.dividerColor,
        //   width: 1,
        // ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            SfPdfViewer.network(
              widget.pdfUrl!,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
              canShowScrollHead: false,
              canShowScrollStatus: true,
              onDocumentLoaded: (details) {
                setState(() {
                  _isPdfLoading = false;
                });
              },
              onDocumentLoadFailed: (details) {
                setState(() {
                  _isPdfLoading = false;
                  _pdfError = details.error;
                });
                SnackbarUtils.showError(
                  context,
                  'Failed to load preview: ${details.description}',
                );
              },
            ),

            if (_isPdfLoading)
              Container(
                color: theme.scaffoldBackgroundColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading preview...',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

            if (_pdfError != null && !_isPdfLoading)
              Container(
                color: theme.scaffoldBackgroundColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Preview Failed',
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unable to load PDF preview. You can still download the PowerPoint file below.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPreviewPlaceholder(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.slideshow_rounded,
              size: 100,
              color: theme.primaryColor.withValues(alpha:0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'PowerPoint Ready!',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Preview not available for this presentation.\nClick the download button below to save it.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.arrow_downward_rounded,
              size: 32,
              color: theme.primaryColor.withValues(alpha:0.5),
            ),
          ],
        ),
      ),
    );
  }
}
