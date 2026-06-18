class AppValidator {
  static String? number(
    String? value, {
    String fieldName = 'Field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }

    if (num.tryParse(value.replaceAll('.', '')) == null) {
      return '$fieldName harus berupa angka';
    }

    return null;
  }
}