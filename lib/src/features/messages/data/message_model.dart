/// Message model representing individual messages in conversations.
/// 
/// This model handles both text messages and media-based Snaps,
/// with support for disappearing message functionality.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Enumeration for different message types
enum MessageType {
  text,
  snap,
  image,
  video,
}

/// Message model for Firestore documents
class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderUsername;
  final MessageType type;
  final String? content;  // Text content for text messages
  final String? mediaUrl; // URL for media messages
  final String? thumbnailUrl; // Thumbnail for videos
  final int? duration; // Duration in seconds for snaps
  final DateTime sentAt;
  final List<String> viewedBy; // List of user IDs who have viewed this message
  final DateTime? expiresAt; // When the message should be deleted
  final bool isGroupMessage;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderUsername,
    required this.type,
    this.content,
    this.mediaUrl,
    this.thumbnailUrl,
    this.duration,
    required this.sentAt,
    required this.viewedBy,
    this.expiresAt,
    required this.isGroupMessage,
  });

  /// Create a MessageModel from a Firestore document
  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return MessageModel(
      id: snapshot.id,
      conversationId: data['conversationId'] as String,
      senderId: data['senderId'] as String,
      senderUsername: data['senderUsername'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'] as String,
        orElse: () => MessageType.text,
      ),
      content: data['content'] as String?,
      mediaUrl: data['mediaUrl'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      duration: data['duration'] as int?,
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      viewedBy: List<String>.from(data['viewedBy'] as List? ?? []),
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      isGroupMessage: data['isGroupMessage'] as bool? ?? false,
    );
  }

  /// Convert MessageModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'type': type.name,
      'content': content,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'sentAt': Timestamp.fromDate(sentAt),
      'viewedBy': viewedBy,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isGroupMessage': isGroupMessage,
    };
  }

  /// Create a copy of MessageModel with updated fields
  MessageModel copyWith({
    String? conversationId,
    String? senderId,
    String? senderUsername,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? thumbnailUrl,
    int? duration,
    DateTime? sentAt,
    List<String>? viewedBy,
    DateTime? expiresAt,
    bool? isGroupMessage,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      sentAt: sentAt ?? this.sentAt,
      viewedBy: viewedBy ?? this.viewedBy,
      expiresAt: expiresAt ?? this.expiresAt,
      isGroupMessage: isGroupMessage ?? this.isGroupMessage,
    );
  }

  /// Check if the message has been viewed by a specific user
  bool hasBeenViewedBy(String userId) {
    return viewedBy.contains(userId);
  }

  /// Check if the message has expired and should be deleted
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if this is a media message (snap, image, or video)
  bool get isMediaMessage {
    return type == MessageType.snap || 
           type == MessageType.image || 
           type == MessageType.video;
  }

  /// Check if this is a disappearing message
  bool get isDisappearing {
    return type == MessageType.snap || expiresAt != null;
  }
} 