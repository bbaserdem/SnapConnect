/// Conversation model representing chat conversations.
/// 
/// This model manages both direct messages between two users
/// and group conversations with multiple participants.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Conversation model for Firestore documents
class ConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantUsernames; // userId -> username mapping
  final bool isGroup;
  final String? groupName;
  final String? groupAvatarUrl;
  final String? lastMessageId;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final DateTime? lastMessageTimestamp;
  final Map<String, DateTime> lastViewedTimestamps; // userId -> timestamp mapping
  final Map<String, int> unreadCounts; // userId -> unread count mapping
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantUsernames,
    required this.isGroup,
    this.groupName,
    this.groupAvatarUrl,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageTimestamp,
    required this.lastViewedTimestamps,
    required this.unreadCounts,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a ConversationModel from a Firestore document
  factory ConversationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    
    // Parse lastViewedTimestamps
    final lastViewedData = data['lastViewedTimestamps'] as Map<String, dynamic>? ?? {};
    final lastViewedTimestamps = <String, DateTime>{};
    lastViewedData.forEach((key, value) {
      if (value is Timestamp) {
        lastViewedTimestamps[key] = value.toDate();
      }
    });

    // Parse unreadCounts
    final unreadData = data['unreadCounts'] as Map<String, dynamic>? ?? {};
    final unreadCounts = <String, int>{};
    unreadData.forEach((key, value) {
      unreadCounts[key] = value as int? ?? 0;
    });

    // Parse participantUsernames
    final usernameData = data['participantUsernames'] as Map<String, dynamic>? ?? {};
    final participantUsernames = <String, String>{};
    usernameData.forEach((key, value) {
      participantUsernames[key] = value as String;
    });

    return ConversationModel(
      id: snapshot.id,
      participantIds: List<String>.from(data['participantIds'] as List),
      participantUsernames: participantUsernames,
      isGroup: data['isGroup'] as bool? ?? false,
      groupName: data['groupName'] as String?,
      groupAvatarUrl: data['groupAvatarUrl'] as String?,
      lastMessageId: data['lastMessageId'] as String?,
      lastMessageContent: data['lastMessageContent'] as String?,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      lastMessageTimestamp: data['lastMessageTimestamp'] != null 
          ? (data['lastMessageTimestamp'] as Timestamp).toDate()
          : null,
      lastViewedTimestamps: lastViewedTimestamps,
      unreadCounts: unreadCounts,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert ConversationModel to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    // Convert lastViewedTimestamps to Firestore format
    final lastViewedData = <String, Timestamp>{};
    lastViewedTimestamps.forEach((key, value) {
      lastViewedData[key] = Timestamp.fromDate(value);
    });

    return {
      'participantIds': participantIds,
      'participantUsernames': participantUsernames,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupAvatarUrl': groupAvatarUrl,
      'lastMessageId': lastMessageId,
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTimestamp': lastMessageTimestamp != null 
          ? Timestamp.fromDate(lastMessageTimestamp!)
          : null,
      'lastViewedTimestamps': lastViewedData,
      'unreadCounts': unreadCounts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy of ConversationModel with updated fields
  ConversationModel copyWith({
    List<String>? participantIds,
    Map<String, String>? participantUsernames,
    bool? isGroup,
    String? groupName,
    String? groupAvatarUrl,
    String? lastMessageId,
    String? lastMessageContent,
    String? lastMessageSenderId,
    DateTime? lastMessageTimestamp,
    Map<String, DateTime>? lastViewedTimestamps,
    Map<String, int>? unreadCounts,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      id: id,
      participantIds: participantIds ?? this.participantIds,
      participantUsernames: participantUsernames ?? this.participantUsernames,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      groupAvatarUrl: groupAvatarUrl ?? this.groupAvatarUrl,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastViewedTimestamps: lastViewedTimestamps ?? this.lastViewedTimestamps,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the display name for the conversation
  String getDisplayName(String currentUserId) {
    if (isGroup) {
      return groupName ?? 'Group Chat';
    }
    
    // For direct messages, return the other participant's username
    final otherParticipantId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    
    return participantUsernames[otherParticipantId] ?? 'Unknown User';
  }

  /// Get unread count for a specific user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  /// Check if the conversation has unread messages for a user
  bool hasUnreadMessages(String userId) {
    return getUnreadCount(userId) > 0;
  }

  /// Get the other participant ID in a direct message conversation
  String? getOtherParticipantId(String currentUserId) {
    if (isGroup) return null;
    
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Generate a conversation ID for a direct message between two users
  static String generateDirectConversationId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return 'direct_${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Check if a user is a participant in this conversation
  bool isParticipant(String userId) {
    return participantIds.contains(userId);
  }
} 