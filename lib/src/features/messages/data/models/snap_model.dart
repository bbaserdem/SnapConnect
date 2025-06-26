// Snap model representing media attachments in messages.
//
// This model handles photo and video snaps with duration settings,
// Firebase Storage references, and metadata.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Snap model for media attachments
class SnapModel {
  /// Unique snap identifier
  final String snapId;

  /// Message ID this snap belongs to
  final String messageId;

  /// Conversation ID this snap belongs to
  final String conversationId;

  /// User ID who created the snap
  final String senderId;

  /// Firebase Storage path for the media file
  final String storagePath;

  /// Firebase Storage download URL
  final String? downloadUrl;

  /// Local file path (for offline access)
  final String? localPath;

  /// Media type
  final SnapMediaType mediaType;

  /// View duration in seconds (1-10)
  final int duration;

  /// Upload timestamp
  final DateTime createdAt;

  /// File size in bytes
  final int? fileSizeBytes;

  /// Image/video dimensions
  final int? width;
  final int? height;

  /// Thumbnail storage path (for videos)
  final String? thumbnailPath;

  const SnapModel({
    required this.snapId,
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.storagePath,
    this.downloadUrl,
    this.localPath,
    required this.mediaType,
    this.duration = 5,
    required this.createdAt,
    this.fileSizeBytes,
    this.width,
    this.height,
    this.thumbnailPath,
  });

  /// Create a SnapModel from Firestore document
  factory SnapModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data()!;
    
    return SnapModel(
      snapId: snapshot.id,
      messageId: data['messageId'] as String,
      conversationId: data['conversationId'] as String,
      senderId: data['senderId'] as String,
      storagePath: data['storagePath'] as String,
      downloadUrl: data['downloadUrl'] as String?,
      mediaType: SnapMediaType.values.firstWhere(
        (e) => e.name == (data['mediaType'] ?? 'photo'),
        orElse: () => SnapMediaType.photo,
      ),
      duration: (data['duration'] as int?) ?? 5,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      fileSizeBytes: data['fileSizeBytes'] as int?,
      width: data['width'] as int?,
      height: data['height'] as int?,
      thumbnailPath: data['thumbnailPath'] as String?,
    );
  }

  /// Convert SnapModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'senderId': senderId,
      'storagePath': storagePath,
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
      'mediaType': mediaType.name,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      if (fileSizeBytes != null) 'fileSizeBytes': fileSizeBytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
    };
  }

  /// Create a copy with updated fields
  SnapModel copyWith({
    String? snapId,
    String? messageId,
    String? conversationId,
    String? senderId,
    String? storagePath,
    String? downloadUrl,
    String? localPath,
    SnapMediaType? mediaType,
    int? duration,
    DateTime? createdAt,
    int? fileSizeBytes,
    int? width,
    int? height,
    String? thumbnailPath,
  }) {
    return SnapModel(
      snapId: snapId ?? this.snapId,
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      localPath: localPath ?? this.localPath,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  /// Get file extension based on media type
  String get fileExtension {
    switch (mediaType) {
      case SnapMediaType.photo:
        return 'jpg';
      case SnapMediaType.video:
        return 'mp4';
    }
  }

  /// Get file name for storage
  String getFileName() {
    final timestamp = createdAt.millisecondsSinceEpoch;
    return 'snap_$timestamp.$fileExtension';
  }

  /// Get Firebase Storage path
  String getStoragePath() {
    return 'snaps/$conversationId/$messageId/${getFileName()}';
  }

  /// Get thumbnail path for videos
  String? getThumbnailPath() {
    if (mediaType != SnapMediaType.video) return null;
    final timestamp = createdAt.millisecondsSinceEpoch;
    return 'snaps/$conversationId/$messageId/thumb_$timestamp.jpg';
  }

  /// Get formatted file size
  String getFormattedFileSize() {
    if (fileSizeBytes == null) return 'Unknown size';
    
    final bytes = fileSizeBytes!;
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get aspect ratio
  double? get aspectRatio {
    if (width == null || height == null) return null;
    return width! / height!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SnapModel && other.snapId == snapId;
  }

  @override
  int get hashCode => snapId.hashCode;
}

/// Enumeration for snap media types
enum SnapMediaType {
  photo,
  video,
} 