class AppConstants {
  static const String appName = 'MagicSlides';

  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserEmail = 'userEmail';
  static const String keyThemeMode = 'themeMode';

  static const String defaultTemplateType = 'default';
  static const String editableTemplateType = 'editable';

  static const int defaultSlideCount = 10;
  static const int minSlideCount = 1;
  static const int maxSlideCount = 50;
  static const String defaultLanguage = 'en';
  static const String defaultModel = 'gpt-4';

  static const List<String> languages = [
    'en', 'es', 'fr', 'de', 'it', 'pt', 'ru', 'ja', 'ko', 'zh'
  ];

  static const List<String> models = ['gpt-4', 'gpt-3.5'];

  static const List<String> presentationFor = [
    'student',
    'teacher',
    'business',
    'healthcare professionals',
    'general audience'
  ];

  static const List<String> watermarkPositions = [
    'TopLeft',
    'TopRight',
    'BottomLeft',
    'BottomRight',
    'Center'
  ];

  static const List<String> defaultTemplates = [
    'bullet-point1',
    'bullet-point2',
    'bullet-point4',
    'bullet-point5',
    'bullet-point6',
    'bullet-point7',
    'bullet-point8',
    'bullet-point9',
    'bullet-point10',
    'custom2',
    'custom3',
    'custom4',
    'custom5',
    'custom6',
    'custom7',
    'custom8',
    'custom9',
    'verticalBulletPoint1',
    'verticalCustom1',
  ];

  static const List<String> editableTemplates = [
    'ed-bullet-point9',
    'ed-bullet-point7',
    'ed-bullet-point6',
    'ed-bullet-point5',
    'ed-bullet-point2',
    'ed-bullet-point4',
    'Custom gold 1',
    'custom Dark 1',
    'custom sync 5',
    'custom sync 4',
    'custom sync 6',
    'custom sync 1',
    'custom sync 2',
    'custom sync 3',       
    'custom-ed-7',
    'custom-ed-8',
    'custom-ed-9',
    'pitchdeckorignal',
    'pitch-deck-3',
    'pitch-deck-2',
    'custom-ed-10',
    'custom-ed-11',
    'custom-ed-12',
    'ed-bullet-point1',
  ];
}