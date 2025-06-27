/// Cached conversation model for local Isar database storage.
/// 
/// This model is used to cache conversation data locally for faster
/// initial loads and basic offline access.

import 'dart:convert';
import 'package:isar/isar.dart';

part 'cached_conversation.g.dart';

@collection
class CachedConversation {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String conversationId;

  late List<String> participantIds;
  
  // Store as JSON string since Isar doesn't support Map directly
  late String participantUsernamesJson;
  
  late bool isGroup;
  
  String? groupName;
  
  String? groupAvatarUrl;
  
  String? lastMessageId;
  
  String? lastMessageContent;
  
  String? lastMessageSenderId;
  
  @Index()
  DateTime? lastMessageTimestamp;
  
  // Store as JSON string since Isar doesn't support Map directly
  late String lastViewedTimestampsJson;
  
  // Store as JSON string since Isar doesn't support Map directly
  late String unreadCountsJson;
  
  late DateTime createdAt;
  
  late DateTime updatedAt;

  CachedConversation();

  /// Create from ConversationModel
  CachedConversation.fromConversationModel(dynamic conversationModel) {
    conversationId = conversationModel.id;
    participantIds = conversationModel.participantIds;
    participantUsernamesJson = jsonEncode(conversationModel.participantUsernames);
    isGroup = conversationModel.isGroup;
    groupName = conversationModel.groupName;
    groupAvatarUrl = conversationModel.groupAvatarUrl;
    lastMessageId = conversationModel.lastMessageId;
    lastMessageContent = conversationModel.lastMessageContent;
    lastMessageSenderId = conversationModel.lastMessageSenderId;
    lastMessageTimestamp = conversationModel.lastMessageTimestamp;
    
    // Convert DateTime maps to timestamp maps for JSON serialization
    final lastViewedMap = <String, int>{};
    conversationModel.lastViewedTimestamps?.forEach((key, value) {
      lastViewedMap[key] = (value as DateTime).millisecondsSinceEpoch;
    });
    lastViewedTimestampsJson = jsonEncode(lastViewedMap);
    
    unreadCountsJson = jsonEncode(conversationModel.unreadCounts);
    createdAt = conversationModel.createdAt;
    updatedAt = conversationModel.updatedAt;
  }

  /// Get participant usernames as Map
  @ignore
  Map<String, String> get participantUsernames {
    try {
      return Map<String, String>.from(jsonDecode(participantUsernamesJson));
    } catch (e) {
      return <String, String>{};
    }
  }

  /// Get last viewed timestamps as Map
  @ignore
  Map<String, DateTime> get lastViewedTimestamps {
    try {
      final timestampMap = Map<String, int>.from(jsonDecode(lastViewedTimestampsJson));
      final dateTimeMap = <String, DateTime>{};
      timestampMap.forEach((key, value) {
        dateTimeMap[key] = DateTime.fromMillisecondsSinceEpoch(value);
      });
      return dateTimeMap;
    } catch (e) {
      return <String, DateTime>{};
    }
  }

  /// Get unread counts as Map
  @ignore
  Map<String, int> get unreadCounts {
    try {
      return Map<String, int>.from(jsonDecode(unreadCountsJson));
    } catch (e) {
      return <String, int>{};
    }
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
} 