// Message model representing individual chat messages.
//
// This model supports text messages and snap references with
// disappearing functionality and read status tracking.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Message model for Firestore storage
class MessageModel {
  /// Unique message identifier
  final String messageId;

  /// Conversation ID this message belongs to
  final String conversationId;

  /// ID of the user who sent the message
  final String senderId;

  /// Username of the sender (for display)
  final String senderUsername;

  /// Text content (for text messages)
  final String? content;

  /// Firebase Storage reference for snap messages
  final String? snapRef;

  /// Snap duration in seconds (1-10)
  final int? snapDuration;

  /// Message timestamp
  final DateTime timestamp;

  /// Map of user IDs to view timestamps
  final Map<String, DateTime> viewedBy;

  /// Expiration timestamp for disappearing messages
  final DateTime? expiresAt;

  /// Message type
  final MessageType messageType;

  const MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderUsername,
    this.content,
    this.snapRef,
    this.snapDuration,
    required this.timestamp,
    required this.viewedBy,
    this.expiresAt,
    required this.messageType,
  });

  /// Create a MessageModel from Firestore document
  factory MessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String currentUserId, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data()!;
    
    // Parse viewedBy map
    final viewedByData = data['viewedBy'] as Map<String, dynamic>? ?? {};
    final viewedBy = <String, DateTime>{};
    for (final entry in viewedByData.entries) {
      if (entry.value is Timestamp) {
        viewedBy[entry.key] = (entry.value as Timestamp).toDate();
      }
    }
    
    return MessageModel(
      messageId: snapshot.id,
      conversationId: data['conversationId'] as String,
      senderId: data['senderId'] as String,
      senderUsername: data['senderUsername'] as String,
      content: data['content'] as String?,
      snapRef: data['snapRef'] as String?,
      snapDuration: data['snapDuration'] as int?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      viewedBy: viewedBy,
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      messageType: MessageType.values.firstWhere(
        (e) => e.name == (data['messageType'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
    );
  }

  /// Convert MessageModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    final viewedByFirestore = <String, Timestamp>{};
    for (final entry in viewedBy.entries) {
      viewedByFirestore[entry.key] = Timestamp.fromDate(entry.value);
    }

    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      if (content != null) 'content': content,
      if (snapRef != null) 'snapRef': snapRef,
      if (snapDuration != null) 'snapDuration': snapDuration,
      'timestamp': Timestamp.fromDate(timestamp),
      'viewedBy': viewedByFirestore,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      'messageType': messageType.name,
    };
  }

  /// Create a copy with updated fields
  MessageModel copyWith({
    String? messageId,
    String? conversationId,
    String? senderId,
    String? senderUsername,
    String? content,
    String? snapRef,
    int? snapDuration,
    DateTime? timestamp,
    Map<String, DateTime>? viewedBy,
    DateTime? expiresAt,
    MessageType? messageType,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      content: content ?? this.content,
      snapRef: snapRef ?? this.snapRef,
      snapDuration: snapDuration ?? this.snapDuration,
      timestamp: timestamp ?? this.timestamp,
      viewedBy: viewedBy ?? this.viewedBy,
      expiresAt: expiresAt ?? this.expiresAt,
      messageType: messageType ?? this.messageType,
    );
  }

  /// Mark message as viewed by a user
  MessageModel markAsViewed(String userId) {
    final newViewedBy = Map<String, DateTime>.from(viewedBy);
    newViewedBy[userId] = DateTime.now();
    
    DateTime? newExpiresAt = expiresAt;
    if (messageType == MessageType.snap && !viewedBy.containsKey(userId)) {
      // Set expiration for snap messages (delete after viewing)
      newExpiresAt = DateTime.now().add(const Duration(seconds: 30));
    }
    
    return copyWith(
      viewedBy: newViewedBy,
      expiresAt: newExpiresAt,
    );
  }

  /// Check if message has been viewed by a user
  bool hasBeenViewedBy(String userId) {
    return viewedBy.containsKey(userId);
  }

  /// Check if message has expired
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get display content for the message
  String getDisplayContent() {
    switch (messageType) {
      case MessageType.text:
        return content ?? '';
      case MessageType.snap:
        return '📸 Snap';
    }
  }

  /// Get time ago string for display
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${difference.inDays ~/ 7}w';
    }
  }

  /// Check if message is from current user
  bool isSentByMe(String currentUserId) {
    return senderId == currentUserId;
  }

  /// Check if message has been read by current user
  bool isReadByMe(String currentUserId) {
    return hasBeenViewedBy(currentUserId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel && other.messageId == messageId;
  }

  @override
  int get hashCode => messageId.hashCode;
}

/// Enumeration for message types
enum MessageType {
  text,
  snap,
} 