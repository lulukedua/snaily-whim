import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<File?> pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image == null) return null;

    final file = File(image.path);

    final size = await file.length();

    if (size > 5 * 1024 * 1024) {
      throw Exception('Ukuran gambar maksimal 5 MB');
    }

    return file;
  }
}
