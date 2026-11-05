import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ecoach_pro/core/theme/app_colors.dart';
import 'package:ecoach_pro/core/theme/app_text_styles.dart';
import 'package:ecoach_pro/core/utils/logger.dart';
import 'package:ecoach_pro/core/utils/responsive.dart';
import 'package:ecoach_pro/core/widgets/app_toast.dart';
import 'package:ecoach_pro/features/tracker/domain/repositories/tracker_repository.dart';

/// Camera / gallery picker for the match photo (JPG or PNG, up to 20 MB).
class ImagePickerMatchPhotoPicker implements MatchPhotoPicker {
  static const int _maxBytes = 20 * 1024 * 1024;
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pick() async {
    final source = await Get.bottomSheet<ImageSource>(
      const _SourceSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
    if (source == null) return null;

    try {
      // maxWidth / imageQuality also re-encode iPhone HEIC photos to JPEG.
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        imageQuality: 85,
      );
      if (file == null) return null;

      final path = file.path;
      final ext = path.toLowerCase().split('.').last;
      if (ext != 'jpg' && ext != 'jpeg' && ext != 'png') {
        AppToast.error('Please choose a JPG or PNG image');
        return null;
      }
      if (await File(path).length() > _maxBytes) {
        AppToast.error('The image is too large (max 20MB)');
        return null;
      }
      return path;
    } on PlatformException catch (error, stackTrace) {
      AppLogger.error('Photo pick failed', error: error, stackTrace: stackTrace);
      final denied = error.code.contains('denied');
      AppToast.error(denied
          ? 'Permission denied. Please allow photo / camera access in Settings.'
          : 'Could not get the photo. Please try again.');
      return null;
    } catch (error, stackTrace) {
      AppLogger.error('Photo pick failed', error: error, stackTrace: stackTrace);
      AppToast.error('Could not get the photo. Please try again.');
      return null;
    }
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    final s = Responsive.of(context).scale;
    Widget option(IconData icon, String label, ImageSource source) => ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8 * s),
          leading: Icon(icon, color: AppColors.white, size: 26 * s),
          title: Text(label, style: AppTextStyles.dialogBody.scaled(s)),
          onTap: () => Get.back<ImageSource>(result: source),
        );

    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 12 * s),
        decoration: BoxDecoration(
          color: AppColors.popupBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Upload Image', style: AppTextStyles.dialogTitle.scaled(s)),
            SizedBox(height: 6 * s),
            option(Icons.photo_camera_outlined, 'Take a photo', ImageSource.camera),
            option(Icons.photo_library_outlined, 'Choose from gallery', ImageSource.gallery),
          ],
        ),
      ),
    );
  }
}
