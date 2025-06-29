/// Messaging repository that handles all messaging operations.
/// 
/// This repository manages conversations and messages using Firestore
/// for real-time sync and Isar for local caching and offline access.

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as ff;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'message_model.dart';
import 'conversation_model.dart';
import 'cached_conversation.dart';
import 'cached_message.dart';
import '../../../common/utils/error_handler.dart';
import 'media_upload_service.dart';
import 'local_cache_service.dart';
import 'conversation_service.dart';

/// Provider for the messaging repository
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepository(
    firestore: ff.FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
    auth: FirebaseAuth.instance,
  );
});

/// Repository class that handles all messaging operations
class MessagingRepository {
  final ff.FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;
  final MediaUploadService _mediaService;
  final LocalCacheService _cacheService;
  final ConversationService _conversationService;
  final Uuid _uuid = const Uuid();

  MessagingRepository({
    required this.firestore,
    required this.storage,
    required this.auth,
  })  : _mediaService = MediaUploadService(storage: storage),
        _cacheService = LocalCacheService(),
        _conversationService = ConversationService(firestore: firestore, auth: auth);

  /// Get current user ID
  String? get currentUserId => auth.currentUser?.uid;

  /// Stream of conversations for the current user
  Stream<List<ConversationModel>> getConversationsStream() {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    debugPrint('Creating conversations stream for user: $userId');
    
    return firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      debugPrint('Received conversations snapshot with ${snapshot.docs.length} documents');
      
      final conversations = snapshot.docs
          .map((doc) {
            try {
              return ConversationModel.fromFirestore(doc);
            } catch (e) {
              debugPrint('Error parsing conversation document ${doc.id}: $e');
              return null;
            }
          })
          .where((conv) => conv != null)
          .cast<ConversationModel>()
          .where((conv) => _isVisibleConversation(conv, userId))
          .toList();

      debugPrint('Successfully parsed ${conversations.length} conversations');

      // Cache conversations locally
      _cacheService.cacheConversations(conversations);

      return conversations;
    }).handleError((error) {
      debugPrint('Firestore conversations stream error: $error');
      debugPrint('Error type: ${error.runtimeType}');
      throw error;
    });
  }

  /// Get cached conversations from Isar
  Future<List<CachedConversation>> getCachedConversations() async {
    return _cacheService.getCachedConversations();
  }

  /// Stream of messages for a conversation
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();

      // Cache messages locally
      _cacheService.cacheMessages(messages);

      // Clean up expired messages
      _cleanupExpiredMessages(messages);

      return messages;
    });
  }

  /// Get cached messages for a conversation
  Future<List<CachedMessage>> getCachedMessages(String conversationId) async {
    return _cacheService.getCachedMessages(conversationId);
  }

  /// Create or get a direct conversation between two users
  Future<ConversationModel> createOrGetDirectConversation({
    required String otherUserId,
    required String otherUsername,
  }) {
    return _conversationService.createOrGetDirectConversation(
      otherUserId: otherUserId,
      otherUsername: otherUsername,
    );
  }

  /// Send a text message
  Future<MessageModel> sendTextMessage({
    required String conversationId,
    required String content,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Get user data
      final userDoc = await firestore.collection('users').doc(userId).get();
      final username = userDoc.data()?['username'] as String? ?? 'Unknown';

      // Create message
      final messageId = _uuid.v4();
      final now = DateTime.now();
      
      final message = MessageModel(
        id: messageId,
        conversationId: conversationId,
        senderId: userId,
        senderUsername: username,
        type: MessageType.text,
        content: content,
        sentAt: now,
        viewedBy: [userId], // Sender has viewed the message
        isGroupMessage: false,
      );

      // Save message to Firestore
      await firestore
          .collection('messages')
          .doc(messageId)
          .set(message.toFirestore());

      // Update conversation's last message
      await _conversationService.updateLastMessage(
        conversationId: conversationId,
        lastMessageId: messageId,
        lastMessageContent: content,
        lastMessageSenderId: userId,
        lastMessageTimestamp: now,
      );

      await _conversationService.incrementUnreadCounts(conversationId, userId);

      return message;
    } catch (e) {
      ErrorHandler.logError('send text message', e);
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  /// Send a snap (media message)
  Future<MessageModel> sendSnapMessage({
    required String conversationId,
    required File mediaFile,
    required MessageType type,
    int? duration,
    File? thumbnailFile,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Upload media to Firebase Storage
      final mediaUrl = await _mediaService.uploadMedia(file: mediaFile, type: type);
      String? thumbnailUrl;
      
      if (thumbnailFile != null) {
        thumbnailUrl = await _mediaService.uploadMedia(file: thumbnailFile, type: MessageType.image);
      }

      // Get user data
      final userDoc = await firestore.collection('users').doc(userId).get();
      final username = userDoc.data()?['username'] as String? ?? 'Unknown';

      // Create message
      final messageId = _uuid.v4();
      final now = DateTime.now();
      final expiresAt = (type == MessageType.snap && duration != null && duration > 0)
          ? now.add(Duration(seconds: duration))
          : null;
      
      final message = MessageModel(
        id: messageId,
        conversationId: conversationId,
        senderId: userId,
        senderUsername: username,
        type: type,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        duration: duration,
        sentAt: now,
        viewedBy: [userId], // Sender has viewed the message
        expiresAt: expiresAt,
        isGroupMessage: false,
      );

      // Save message to Firestore
      await firestore
          .collection('messages')
          .doc(messageId)
          .set(message.toFirestore());

      // Update conversation's last message
      final lastMessageContent = type == MessageType.snap
          ? '📸 Snap'
          : type == MessageType.image
              ? '🖼️ Photo'
              : '🎥 Video';

      await _conversationService.updateLastMessage(
        conversationId: conversationId,
        lastMessageId: messageId,
        lastMessageContent: lastMessageContent,
        lastMessageSenderId: userId,
        lastMessageTimestamp: now,
      );

      await _conversationService.incrementUnreadCounts(conversationId, userId);

      return message;
    } catch (e) {
      ErrorHandler.logError('send snap message', e);
      throw Exception('Failed to send snap: ${e.toString()}');
    }
  }

  /// Mark a message as viewed
  Future<void> markMessageAsViewed(String messageId, String userId) async {
    try {
      // First, get the message to check if it's a snap and who sent it
      final messageDoc = await firestore.collection('messages').doc(messageId).get();
      if (!messageDoc.exists) return;
      
      final messageData = messageDoc.data()!;
      final messageType = messageData['type'] as String?;
      final senderId = messageData['senderId'] as String?;
      final viewedBy = List<String>.from(messageData['viewedBy'] as List? ?? []);
      
      // Check if user already viewed this message
      if (viewedBy.contains(userId)) return;
      
      // For snaps, mark as expired when viewed by someone other than the sender
      final isSnap = messageType == 'snap';
      final isViewedByRecipient = isSnap && senderId != userId;
      
      final updateData = <String, dynamic>{
        'viewedBy': ff.FieldValue.arrayUnion([userId]),
      };
      
      // Mark snap as expired when viewed by recipient
      if (isViewedByRecipient) {
        updateData['isExpired'] = true;
      }
      
      await firestore.collection('messages').doc(messageId).update(updateData);
    } catch (e) {
      ErrorHandler.logError('mark message as viewed', e);
    }
  }

  /// Clean up expired messages
  Future<void> _cleanupExpiredMessages(List<MessageModel> messages) async {
    final uid = currentUserId;
    final expiredMessages = messages.where((msg) =>
        msg.hasExpired &&
        !msg.isExpired &&
        msg.senderId == uid &&
        msg.type != MessageType.snap // never auto-delete snaps; they rely on TTL
    ).toList();
    
    for (final message in expiredMessages) {
      await _deleteMessage(message);
    }
  }

  /// Delete a message from Firestore and Storage
  Future<void> _deleteMessage(MessageModel message) async {
    final uid = currentUserId;
    if (uid != message.senderId) return; // only sender cleans up
    try {
      // Delete media from Storage if it exists
      if (message.mediaUrl != null) {
        try {
          await storage.refFromURL(message.mediaUrl!).delete();
        } catch (e) {
          // Ignore storage deletion errors
        }
      }

      if (message.thumbnailUrl != null) {
        try {
          await storage.refFromURL(message.thumbnailUrl!).delete();
        } catch (e) {
          // Ignore storage deletion errors
        }
      }

      // Instead of deleting, mark as expired so bubble remains
      await firestore.collection('messages').doc(message.id).update({
        'isExpired': true,
        'mediaUrl': null,
        'thumbnailUrl': null,
      });

      // Remove from local cache
      await _cacheService.removeMessageById(message.id);
    } catch (e) {
      ErrorHandler.logError('delete message', e);
    }
  }

  /// Clear local cache
  Future<void> clearLocalCache() async {
    try {
      await _cacheService.clear();
    } catch (e) {
      ErrorHandler.logError('clear local cache', e);
    }
  }

  /// Test Firestore connectivity and ensure collections exist
  Future<bool> testFirestoreConnectivity() async {
    try {
      debugPrint('Testing Firestore connectivity...');
      
      // Check if user is authenticated first
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('Firestore connectivity test failed: User not authenticated');
        return false;
      }
      
      debugPrint('Testing Firestore connectivity for user: $userId');
      
      // Try a simple read operation with timeout
      final testQuery = await firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('Firestore connection timeout');
              throw Exception('Firestore connection timeout');
            },
          );
      
      debugPrint('Firestore connectivity test successful - found ${testQuery.docs.length} documents');
      return true;
    } catch (e) {
      debugPrint('Firestore connectivity test failed: $e');
      return false;
    }
  }

  /// Create a new group conversation with up to 10 participants.
  Future<ConversationModel> createGroupConversation({
    required String groupName,
    required List<String> participantIds,
    required Map<String, String> participantUsernames,
  }) {
    return _conversationService.createGroupConversation(
      groupName: groupName,
      participantIds: participantIds,
      participantUsernames: participantUsernames,
    );
  }

  /// Leave a conversation (direct or group). Adds current uid to deletedFor array.
  Future<void> leaveConversation(String conversationId) {
    return _conversationService.leaveConversation(conversationId);
  }

  /// Internal helper to determine if a conversation is visible for current user
  bool _isVisibleConversation(ConversationModel conv, String uid) {
    return !conv.deletedFor.contains(uid);
  }
} 