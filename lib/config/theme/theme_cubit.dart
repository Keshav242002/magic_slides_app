import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final StorageService _storageService;

  ThemeCubit({required StorageService storageService})
      : _storageService = storageService,
        super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDarkMode = _storageService.getBool(AppConstants.keyThemeMode) ?? false;
    emit(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _storageService.saveBool(
      AppConstants.keyThemeMode,
      newMode == ThemeMode.dark,
    );
    emit(newMode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _storageService.saveBool(
      AppConstants.keyThemeMode,
      mode == ThemeMode.dark,
    );
    emit(mode);
  }
}
