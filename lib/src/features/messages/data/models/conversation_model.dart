// Conversation model representing chat conversations.
//
// This model supports Firestore storage for real-time messaging.
// Isar caching will be added in a future update.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_model.dart';

/// Conversation model for Firestore storage
class ConversationModel {
  /// Unique conversation identifier
  final String conversationId;

  /// List of participant user IDs
  final List<String> participants;

  /// Map of participant data (userId: username)
  final Map<String, String> participantUsernames;

  /// Last message content (for preview)
  final String? lastMessageContent;

  /// Last message timestamp
  final DateTime? lastMessageTime;

  /// Conversation creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Conversation type: 'direct' or 'group'
  final ConversationType type;

  /// Group name (only for group conversations)
  final String? groupName;

  /// Last message sender ID
  final String? lastMessageSenderId;

  /// Last message type
  final MessageType? lastMessageType;

  const ConversationModel({
    required this.conversationId,
    required this.participants,
    required this.participantUsernames,
    this.lastMessageContent,
    this.lastMessageTime,
    this.createdAt,
    this.updatedAt,
    required this.type,
    this.groupName,
    this.lastMessageSenderId,
    this.lastMessageType,
  });

  /// Create a ConversationModel from Firestore document
  factory ConversationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, [
    SnapshotOptions? options,
  ]) {
    final data = snapshot.data()!;
    
    return ConversationModel(
      conversationId: snapshot.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantUsernames: Map<String, String>.from(
        data['participantUsernames'] ?? {},
      ),
      lastMessageContent: data['lastMessage']?['content'] as String?,
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      type: ConversationType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'direct'),
        orElse: () => ConversationType.direct,
      ),
      groupName: data['groupName'] as String?,
      lastMessageSenderId: data['lastMessage']?['senderId'] as String?,
      lastMessageType: data['lastMessage']?['type'] != null
          ? MessageType.values.firstWhere(
              (e) => e.name == data['lastMessage']['type'],
              orElse: () => MessageType.text,
            )
          : null,
    );
  }

  /// Convert ConversationModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    final lastMessage = lastMessageContent != null || lastMessageSenderId != null
        ? {
            if (lastMessageContent != null) 'content': lastMessageContent,
            if (lastMessageSenderId != null) 'senderId': lastMessageSenderId,
            if (lastMessageType != null) 'type': lastMessageType!.name,
          }
        : null;

    return {
      'participants': participants,
      'participantUsernames': participantUsernames,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageTime != null) 
        'lastMessageTime': Timestamp.fromDate(lastMessageTime!),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
      'type': type.name,
      if (groupName != null) 'groupName': groupName,
    };
  }

  /// Create a copy with updated fields
  ConversationModel copyWith({
    String? conversationId,
    List<String>? participants,
    Map<String, String>? participantUsernames,
    String? lastMessageContent,
    DateTime? lastMessageTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    ConversationType? type,
    String? groupName,
    String? lastMessageSenderId,
    MessageType? lastMessageType,
  }) {
    return ConversationModel(
      conversationId: conversationId ?? this.conversationId,
      participants: participants ?? this.participants,
      participantUsernames: participantUsernames ?? this.participantUsernames,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      groupName: groupName ?? this.groupName,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageType: lastMessageType ?? this.lastMessageType,
    );
  }

  /// Get display name for the conversation
  String getDisplayName(String currentUserId) {
    if (type == ConversationType.group) {
      return groupName ?? 'Group Chat';
    }
    
    // For direct messages, return the other participant's username
    final otherParticipant = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    
    return participantUsernames[otherParticipant] ?? 'Unknown User';
  }

  /// Get other participant ID (for direct messages)
  String? getOtherParticipantId(String currentUserId) {
    if (type == ConversationType.group) return null;
    
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode => conversationId.hashCode;
}

/// Enumeration for conversation types
enum ConversationType {
  direct,
  group,
} 