/// Media upload helper service for MessagingRepository.
///
/// Responsible solely for uploading files to Firebase Storage and returning
/// their download URLs.  Keeping this logic isolated makes
/// `messaging_repository.dart` smaller and focused on business rules.

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'message_model.dart';

/// Small helper that encapsulates media uploading boilerplate.
class MediaUploadService {
  /// Creates a new [MediaUploadService].
  const MediaUploadService({required this.storage});

  /// Firebase Storage instance used for uploads.
  final FirebaseStorage storage;

  /// UUID generator for unique filenames.
  static const _uuid = Uuid();

  /// Upload a media [file] of the given [type] and return the download URL.
  ///
  /// Throws if the file does not exist or the upload fails.
  Future<String> uploadMedia({
    required File file,
    required MessageType type,
  }) async {
    if (!await file.exists()) {
      throw Exception('Local media file not found at ${file.path}');
    }

    final fileName = '${_uuid.v4()}.${_getFileExtension(type)}';
    final ref = storage.ref().child('messages').child(fileName);

    final metadata = SettableMetadata(contentType: _getContentType(type));

    final snapshot = await ref.putFile(file, metadata);
    return snapshot.ref.getDownloadURL();
  }

  /// Resolve the proper MIME type for [type].
  String _getContentType(MessageType type) {
    switch (type) {
      case MessageType.image:
      case MessageType.snap:
        return 'image/jpeg';
      case MessageType.video:
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  /// Get file extension for message [type].
  String _getFileExtension(MessageType type) {
    switch (type) {
      case MessageType.image:
      case MessageType.snap:
        return 'jpg';
      case MessageType.video:
        return 'mp4';
      default:
        return 'dat';
    }
  }
} 