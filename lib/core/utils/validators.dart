class Validators {

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateTopic(String? value) {
    if (value == null || value.isEmpty) {
      return 'Topic is required';
    }

    if (value.trim().length < 3) {
      return 'Topic must be at least 3 characters';
    }

    return null;
  }

  static String? validateSlideCount(String? value, {int min = 1, int max = 50}) {
    if (value == null || value.isEmpty) {
      return 'Slide count is required';
    }

    final count = int.tryParse(value);
    if (count == null) {
      return 'Please enter a valid number';
    }

    if (count < min || count > max) {
      return 'Slide count must be between $min and $max';
    }

    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final urlRegex = RegExp(
      r'^https?://.+\..+',
      caseSensitive: false,
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  static String? validateNumber(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'This field is required' : null;
    }

    if (int.tryParse(value) == null && double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }
}
