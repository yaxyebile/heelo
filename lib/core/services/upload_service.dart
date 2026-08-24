import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UploadService {
  static final _picker = ImagePicker();

  /// Picks an image from the gallery, uploads it to Supabase 'images' bucket,
  /// and returns the public URL. Shows EasyLoading progress automatically.
  static Future<String?> pickAndUploadImage({String bucketName = 'images'}) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      EasyLoading.show(status: 'Uploading...');

      final file = File(image.path);
      final ext = image.name.split('.').last;
      // create a unique UUID for the file name so it doesn't clash
      final fileName = '${const Uuid().v4()}.$ext';

      // Upload to Supabase
      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(fileName, file);

      // Get Public URL
      final publicUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      EasyLoading.showSuccess('Uploaded');
      return publicUrl;
    } catch (e) {
      EasyLoading.showError('Upload failed: $e');
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Picks a video from the gallery, uploads it to Supabase, and returns the public URL.
  static Future<String?> pickAndUploadVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return null;

      EasyLoading.show(status: 'Uploading video...');

      final file = File(video.path);
      final ext = video.name.split('.').last;
      final fileName = '${const Uuid().v4()}.$ext';

      String activeBucket = 'videos';
      try {
        await Supabase.instance.client.storage
            .from(activeBucket)
            .upload(fileName, file);
      } catch (e) {
        // If 'videos' bucket is not created/accessible, fallback to the default 'images' bucket
        activeBucket = 'images';
        await Supabase.instance.client.storage
            .from(activeBucket)
            .upload(fileName, file);
      }

      // Get Public URL
      final publicUrl = Supabase.instance.client.storage
          .from(activeBucket)
          .getPublicUrl(fileName);

      EasyLoading.showSuccess('Muuqaalka waa la upload-gareeyay!');
      return publicUrl;
    } catch (e) {
      EasyLoading.showError('Muuqaalka upload-kiisa wuxuu ku guuldareystay: $e');
      return null;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
