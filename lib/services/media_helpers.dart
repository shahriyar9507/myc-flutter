import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

/// Size limits from the MyC spec.
class MediaLimits {
  static const int imageMax = 10 * 1024 * 1024;   // 10MB
  static const int videoMax = 100 * 1024 * 1024;  // 100MB
  static const int audioMax = 100 * 1024 * 1024;  // 100MB
  static const int fileMax  = 100 * 1024 * 1024;  // 100MB
}

class MediaHelpers {
  /// Compress an image to <=1080px JPEG q=75 and strip EXIF. Returns bytes
  /// ready for upload. Falls back to the original bytes on failure.
  static Future<Uint8List> compressImage(Uint8List bytes) async {
    try {
      // Decode to strip EXIF and auto-rotate, then re-encode.
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;
      final oriented = img.bakeOrientation(decoded);
      final stripped = img.encodeJpg(oriented, quality: 85);
      final out = await FlutterImageCompress.compressWithList(
        Uint8List.fromList(stripped),
        minWidth: 1080,
        minHeight: 1080,
        quality: 75,
        keepExif: false,
        format: CompressFormat.jpeg,
      );
      return out.isEmpty ? bytes : out;
    } catch (_) {
      return bytes;
    }
  }

  /// Compress a video file. Returns the compressed file path or the original
  /// path if compression fails.
  static Future<String> compressVideo(String path) async {
    try {
      final info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      return info?.file?.path ?? path;
    } catch (_) {
      return path;
    }
  }

  /// Generate a video thumbnail and return its path.
  static Future<String?> videoThumbnail(String path) async {
    try {
      final file = await VideoCompress.getFileThumbnail(path, quality: 70);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static Future<File> writeTemp(List<int> bytes, String ext) async {
    final dir = await getTemporaryDirectory();
    final f = File(p.join(dir.path, 'tmp_${DateTime.now().microsecondsSinceEpoch}.$ext'));
    await f.writeAsBytes(bytes);
    return f;
  }

  /// True if the size is within the limit for this media type.
  static bool withinLimit(int bytes, String type) {
    switch (type) {
      case 'image': return bytes <= MediaLimits.imageMax;
      case 'video': return bytes <= MediaLimits.videoMax;
      case 'audio':
      case 'voice': return bytes <= MediaLimits.audioMax;
      default:      return bytes <= MediaLimits.fileMax;
    }
  }
}
