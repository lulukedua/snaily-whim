import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:snailywhim/core/theme/colors.dart';

enum SnackType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    SnackType type = SnackType.info,
  }) {
    final contentType = _mapType(type);
    final color = _mapColor(type);

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        color: color,
        titleTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        messageTextStyle: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static ContentType _mapType(SnackType type) {
    switch (type) {
      case SnackType.success:
        return ContentType.success;
      case SnackType.error:
        return ContentType.failure;
      case SnackType.warning:
        return ContentType.warning;
      case SnackType.info:
        return ContentType.help;
    }
  }

  static Color _mapColor(SnackType type) {
    switch (type) {
      case SnackType.success:
        return AppColors.bgBtmColor; // hijau sage
      case SnackType.error:
        return AppColors.warningTextColor; // merah
      case SnackType.warning:
        return AppColors.secondaryTextColor; // ungu sekunder
      case SnackType.info:
        return AppColors.primTextColor; // ungu primer
    }
  }
}
