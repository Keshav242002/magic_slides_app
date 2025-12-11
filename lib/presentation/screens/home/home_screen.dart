import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/ppt_request_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../config/theme/theme_cubit.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../preview/preview_screen.dart';
import 'bloc/ppt_bloc.dart';
import 'bloc/ppt_event.dart';
import 'bloc/ppt_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _extraInfoController = TextEditingController();
  final _slideCountController = TextEditingController(
    text: AppConstants.defaultSlideCount.toString(),
  );


  final _watermarkWidthController = TextEditingController(text: '48');
  final _watermarkHeightController = TextEditingController(text: '48');
  final _watermarkUrlController = TextEditingController();

  String _templateType = AppConstants.defaultTemplateType;
  String? _selectedTemplate;

  String _selectedLanguage = AppConstants.defaultLanguage;
  String _selectedModel = AppConstants.defaultModel;
  String? _selectedPresentationFor;

  bool _aiImages = false;
  bool _imageForEachSlide = true;
  bool _googleImage = false;
  bool _googleText = false;
  bool _enableWatermark = false;
  String _watermarkPosition = 'BottomRight';

  bool _showAdvancedOptions = false;

  @override
  void initState() {
    super.initState();
    _topicController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    _extraInfoController.dispose();
    _slideCountController.dispose();
    _watermarkWidthController.dispose();
    _watermarkHeightController.dispose();
    _watermarkUrlController.dispose();
    super.dispose();
  }

  bool _isTopicValid() {
    final topic = _topicController.text.trim();
    return topic.isNotEmpty && topic.length >= 4;
  }

  List<String> _getTemplates() {
    return _templateType == AppConstants.defaultTemplateType
        ? AppConstants.defaultTemplates
        : AppConstants.editableTemplates;
  }

  void _onTemplateTypeChanged(String type) {
    setState(() {
      _templateType = type;
      _selectedTemplate = null;
    });
  }

  void _handleGenerate() {
    if (!_isTopicValid()) {
      SnackbarUtils.showError(context, 'Topic must be at least 4 characters');
      return;
    }

    if (_formKey.currentState!.validate()) {
      final userEmail = context.read<AuthRepository>().getCurrentUserEmail();

      if (userEmail == null) {
        SnackbarUtils.showError(context, 'User email not found');
        return;
      }

      WatermarkModel? watermark;
      if (_enableWatermark && _watermarkUrlController.text.isNotEmpty) {
        watermark = WatermarkModel(
          width: _watermarkWidthController.text,
          height: _watermarkHeightController.text,
          brandURL: _watermarkUrlController.text,
          position: _watermarkPosition,
        );
      }

      final request = PptRequestModel(
        topic: _topicController.text.trim(),
        extraInfoSource: _extraInfoController.text.trim().isEmpty
            ? null
            : _extraInfoController.text.trim(),
        email: userEmail,
        accessId: ApiConstants.accessId,
        template: _selectedTemplate,
        language: _selectedLanguage,
        slideCount: int.tryParse(_slideCountController.text),
        aiImages: _aiImages,
        imageForEachSlide: _imageForEachSlide,
        googleImage: _googleImage,
        googleText: _googleText,
        model: _selectedModel,
        presentationFor: _selectedPresentationFor,
        watermark: watermark,
      );

      context.read<PptBloc>().add(GeneratePptEvent(request: request));
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const SignOutEvent());
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MagicSlides'),
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.light
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: BlocConsumer<PptBloc, PptState>(
        listener: (context, state) {
          if (state is PptError) {
            SnackbarUtils.showError(context, state.message!);
          }
          else if (state is PptGenerated) {
            if (state.response.data?.url != null) {
              SnackbarUtils.showSuccess(
                context,
                'Presentation generated successfully!',
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PreviewScreen(
                    pptUrl: state.response.data!.url!,
                    pdfUrl: state.response.data?.pdfUrl,
                  ),
                ),
              );
            } else {
              SnackbarUtils.showError(
                context,
                state.response.message ?? 'Failed to generate presentation. Please try again.',
              );
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is PptGenerating;
          final canGenerate = _isTopicValid() && !isLoading;

          return SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 48,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Generate Your Presentation',
                            style: theme.textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter a topic and customize your slides',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionCard(
                    title: 'Topic',
                    child: CustomTextField(
                      controller: _topicController,
                      label: 'Enter your topic',
                      hint: 'e.g., Artificial Intelligence in Healthcare',
                      prefixIcon: const Icon(Icons.topic_outlined),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Topic is required';
                        }
                        if (value.trim().length < 4) {
                          return 'Topic must be at least 4 characters';
                        }
                        return null;
                      },
                      enabled: !isLoading,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionCard(
                    title: 'Template Type',
                    child: _buildTemplateTypeSelector(isLoading),
                  ),
                  const SizedBox(height: 16),

                  if (_selectedTemplate != null || _getTemplates().isNotEmpty)
                    _buildSectionCard(
                      title: 'Select Template',
                      child: _buildTemplateDropdown(isLoading),
                    ),
                  const SizedBox(height: 16),

                  _buildAdvancedOptionsToggle(),

                  if (_showAdvancedOptions) ...[
                    const SizedBox(height: 16),
                    _buildAdvancedOptions(isLoading, theme),
                  ],

                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Generate Presentation',
                    onPressed: canGenerate ? _handleGenerate : null,
                    isLoading: isLoading,
                    icon: Icons.auto_awesome,
                  ),

                  if (!_isTopicValid() && _topicController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Topic must be at least 4 characters',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateTypeSelector(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Default'),
            value: AppConstants.defaultTemplateType,
            groupValue: _templateType,
            onChanged: isLoading
                ? null
                : (value) {
              if (value != null) _onTemplateTypeChanged(value);
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Editable'),
            value: AppConstants.editableTemplateType,
            groupValue: _templateType,
            onChanged: isLoading
                ? null
                : (value) {
              if (value != null) _onTemplateTypeChanged(value);
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateDropdown(bool isLoading) {
    final templates = _getTemplates();

    return DropdownButtonFormField2<String>(
      value: _selectedTemplate,
      decoration: const InputDecoration(
        labelText: 'Choose a template',
        prefixIcon: Icon(Icons.dashboard_customize_outlined),
      ),
      isExpanded: true,
      hint: const Text('Select template (optional)'),
      items: templates.map((template) {
        return DropdownMenuItem(
          value: template,
          child: Text(
            template,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: isLoading
          ? null
          : (value) {
        setState(() {
          _selectedTemplate = value;
        });
      },
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildAdvancedOptionsToggle() {
    return Card(
      child: InkWell(
        onTap: () {
          setState(() {
            _showAdvancedOptions = !_showAdvancedOptions;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Advanced Options',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Icon(
                _showAdvancedOptions
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions(bool isLoading, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _extraInfoController,
              label: 'Additional Context (Optional)',
              hint: 'Add any extra information',
              prefixIcon: const Icon(Icons.info_outline),
              enabled: !isLoading,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _slideCountController,
              label: 'Number of Slides',
              hint: '${AppConstants.minSlideCount}-${AppConstants.maxSlideCount}',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.format_list_numbered),
              validator: (value) => Validators.validateSlideCount(
                value,
                min: AppConstants.minSlideCount,
                max: AppConstants.maxSlideCount,
              ),
              enabled: !isLoading,
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField2<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Language',
                prefixIcon: Icon(Icons.language_outlined),
              ),
              items: AppConstants.languages.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(lang.toUpperCase()),
                );
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                if (value != null) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                }
              },
              dropdownStyleData: DropdownStyleData(
                maxHeight: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField2<String>(
              value: _selectedModel,
              decoration: const InputDecoration(
                labelText: 'AI Model',
                prefixIcon: Icon(Icons.psychology_outlined),
              ),
              items: AppConstants.models.map((model) {
                return DropdownMenuItem(
                  value: model,
                  child: Text(model),
                );
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                if (value != null) {
                  setState(() {
                    _selectedModel = value;
                  });
                }
              },
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField2<String>(
              value: _selectedPresentationFor,
              decoration: const InputDecoration(
                labelText: 'Presentation For (Optional)',
                prefixIcon: Icon(Icons.people_outline),
              ),
              hint: const Text('Select audience'),
              items: AppConstants.presentationFor.map((audience) {
                return DropdownMenuItem(
                  value: audience,
                  child: Text(audience),
                );
              }).toList(),
              onChanged: isLoading
                  ? null
                  : (value) {
                setState(() {
                  _selectedPresentationFor = value;
                });
              },
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Divider(color: theme.dividerColor),
            const SizedBox(height: 16),
            Text(
              'Image Options',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('AI Generated Images'),
              subtitle: const Text('Use AI to generate images'),
              value: _aiImages,
              onChanged: isLoading
                  ? null
                  : (value) {
                setState(() {
                  _aiImages = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            SwitchListTile(
              title: const Text('Image on Each Slide'),
              subtitle: const Text('Add image to every slide'),
              value: _imageForEachSlide,
              onChanged: isLoading
                  ? null
                  : (value) {
                setState(() {
                  _imageForEachSlide = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            SwitchListTile(
              title: const Text('Google Images'),
              subtitle: const Text('Use Google image search'),
              value: _googleImage,
              onChanged: isLoading
                  ? null
                  : (value) {
                setState(() {
                  _googleImage = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            SwitchListTile(
              title: const Text('Google Text'),
              subtitle: const Text('Use Google text search'),
              value: _googleText,
              onChanged: isLoading
                  ? null
                  : (value) {
                setState(() {
                  _googleText = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 16),

            Text(
              'Watermark (Optional)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Enable Watermark'),
              value: _enableWatermark,
              onChanged: isLoading
                  ? null
                  : (value) {
                setState(() {
                  _enableWatermark = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            if (_enableWatermark) ...[
              const SizedBox(height: 16),

              CustomTextField(
                controller: _watermarkUrlController,
                label: 'Watermark URL',
                hint: 'https://example.com/logo.png',
                keyboardType: TextInputType.url,
                prefixIcon: const Icon(Icons.link),
                validator: _enableWatermark ? Validators.validateUrl : null,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _watermarkWidthController,
                      label: 'Width',
                      hint: '48',
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _watermarkHeightController,
                      label: 'Height',
                      hint: '48',
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField2<String>(
                value: _watermarkPosition,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  prefixIcon: Icon(Icons.photo_size_select_small),
                ),
                items: AppConstants.watermarkPositions.map((pos) {
                  return DropdownMenuItem(
                    value: pos,
                    child: Text(pos),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                  if (value != null) {
                    setState(() {
                      _watermarkPosition = value;
                    });
                  }
                },
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}