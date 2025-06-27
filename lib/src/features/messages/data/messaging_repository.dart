/// Messaging repository that handles all messaging operations.
/// 
/// This repository manages conversations and messages using Firestore
/// for real-time sync and Isar for local caching and offline access.

import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as ff;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'message_model.dart';
import 'conversation_model.dart';
import 'cached_conversation.dart';
import 'cached_message.dart';
import '../../../common/utils/error_handler.dart';

/// Provider for the messaging repository
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepository(
    firestore: ff.FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
    auth: FirebaseAuth.instance,
  );
});

/// Provider for the Isar database instance
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [CachedConversationSchema, CachedMessageSchema],
    directory: dir.path,
  );
});

/// Repository class that handles all messaging operations
class MessagingRepository {
  final ff.FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;
  final Uuid _uuid = const Uuid();

  Isar? _isar;

  MessagingRepository({
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  /// Initialize the Isar database
  Future<void> initializeIsar() async {
    if (_isar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [CachedConversationSchema, CachedMessageSchema],
      directory: dir.path,
    );
  }

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
          .toList();

      debugPrint('Successfully parsed ${conversations.length} conversations');

      // Cache conversations locally
      _cacheConversations(conversations);

      return conversations;
    }).handleError((error) {
      debugPrint('Firestore conversations stream error: $error');
      debugPrint('Error type: ${error.runtimeType}');
      throw error;
    });
  }

  /// Get cached conversations from Isar
  Future<List<CachedConversation>> getCachedConversations() async {
    await initializeIsar();
    return await _isar!.cachedConversations
        .where()
        .sortByLastMessageTimestampDesc()
        .findAll();
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
      _cacheMessages(messages);

      // Clean up expired messages
      _cleanupExpiredMessages(messages);

      return messages;
    });
  }

  /// Get cached messages for a conversation
  Future<List<CachedMessage>> getCachedMessages(String conversationId) async {
    await initializeIsar();
    return await _isar!.cachedMessages
        .where()
        .conversationIdEqualTo(conversationId)
        .sortBySentAtDesc()
        .limit(50)
        .findAll();
  }

  /// Create or get a direct conversation between two users
  Future<ConversationModel> createOrGetDirectConversation({
    required String otherUserId,
    required String otherUsername,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final conversationId = ConversationModel.generateDirectConversationId(
        userId,
        otherUserId,
      );

      // Check if conversation already exists
      final existingDoc = await firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (existingDoc.exists) {
        return ConversationModel.fromFirestore(existingDoc);
      }

      // Get current user data
      final currentUserDoc = await firestore
          .collection('users')
          .doc(userId)
          .get();
      
      final currentUsername = currentUserDoc.data()?['username'] as String? ?? 'Unknown';

      // Create new conversation
      final now = DateTime.now();
      final conversationData = ConversationModel(
        id: conversationId,
        participantIds: [userId, otherUserId],
        participantUsernames: {
          userId: currentUsername,
          otherUserId: otherUsername,
        },
        isGroup: false,
        lastViewedTimestamps: {
          userId: now,
          otherUserId: now,
        },
        unreadCounts: {
          userId: 0,
          otherUserId: 0,
        },
        createdAt: now,
        updatedAt: now,
      );

      await firestore
          .collection('conversations')
          .doc(conversationId)
          .set(conversationData.toFirestore());

      return conversationData;
    } catch (e) {
      ErrorHandler.logError('create or get direct conversation', e);
      throw Exception('Failed to create conversation: ${e.toString()}');
    }
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
      await _updateConversationLastMessage(
        conversationId: conversationId,
        lastMessageId: messageId,
        lastMessageContent: content,
        lastMessageSenderId: userId,
        lastMessageTimestamp: now,
      );

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
      final mediaUrl = await _uploadMedia(mediaFile, type);
      String? thumbnailUrl;
      
      if (thumbnailFile != null) {
        thumbnailUrl = await _uploadMedia(thumbnailFile, MessageType.image);
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

      await _updateConversationLastMessage(
        conversationId: conversationId,
        lastMessageId: messageId,
        lastMessageContent: lastMessageContent,
        lastMessageSenderId: userId,
        lastMessageTimestamp: now,
      );

      return message;
    } catch (e) {
      ErrorHandler.logError('send snap message', e);
      throw Exception('Failed to send snap: ${e.toString()}');
    }
  }

  /// Mark a message as viewed
  Future<void> markMessageAsViewed(String messageId, String userId) async {
    try {
      await firestore.collection('messages').doc(messageId).update({
        'viewedBy': ff.FieldValue.arrayUnion([userId]),
      });

      // Check if this is a disappearing message that should be deleted
      final messageDoc = await firestore
          .collection('messages')
          .doc(messageId)
          .get();
      
      if (messageDoc.exists) {
        final message = MessageModel.fromFirestore(messageDoc);
        if (message.isDisappearing && message.hasBeenViewedBy(userId)) {
          _scheduleMessageDeletion(message);
        }
      }
    } catch (e) {
      ErrorHandler.logError('mark message as viewed', e);
    }
  }

  /// Upload media file to Firebase Storage
  Future<String> _uploadMedia(File file, MessageType type) async {
    try {
      if (!await file.exists()) {
        throw Exception('Local media file not found at ${file.path}');
      }

      final fileName = '${_uuid.v4()}.${_getFileExtension(type)}';
      final ref = storage.ref().child('messages').child(fileName);

      final metadata = SettableMetadata(contentType: _getContentType(type));

      final snapshot = await ref.putFile(file, metadata);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ErrorHandler.logError('upload media', e);
      throw Exception('Failed to upload media: ${e.toString()}');
    }
  }

  /// Resolve proper MIME type for upload
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

  /// Get file extension for message type
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

  /// Update conversation's last message information
  Future<void> _updateConversationLastMessage({
    required String conversationId,
    required String lastMessageId,
    required String lastMessageContent,
    required String lastMessageSenderId,
    required DateTime lastMessageTimestamp,
  }) async {
    try {
      await firestore.collection('conversations').doc(conversationId).update({
        'lastMessageId': lastMessageId,
        'lastMessageContent': lastMessageContent,
        'lastMessageSenderId': lastMessageSenderId,
        'lastMessageTimestamp': ff.Timestamp.fromDate(lastMessageTimestamp),
        'updatedAt': ff.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ErrorHandler.logError('update conversation last message', e);
    }
  }

  /// Cache conversations locally
  Future<void> _cacheConversations(List<ConversationModel> conversations) async {
    try {
      await initializeIsar();
      if (_isar == null) return;

      final cachedConversations = conversations
          .map((conv) => CachedConversation.fromConversationModel(conv))
          .toList();

      await _isar!.writeTxn(() async {
        await _isar!.cachedConversations.putAll(cachedConversations);
      });
    } catch (e) {
      ErrorHandler.logError('cache conversations', e);
    }
  }

  /// Cache messages locally
  Future<void> _cacheMessages(List<MessageModel> messages) async {
    try {
      await initializeIsar();
      if (_isar == null) return;

      final cachedMessages = messages
          .map((msg) => CachedMessage.fromMessageModel(msg))
          .toList();

      await _isar!.writeTxn(() async {
        await _isar!.cachedMessages.putAll(cachedMessages);
      });
    } catch (e) {
      ErrorHandler.logError('cache messages', e);
    }
  }

  /// Clean up expired messages
  Future<void> _cleanupExpiredMessages(List<MessageModel> messages) async {
    final expiredMessages = messages.where((msg) => msg.hasExpired).toList();
    
    for (final message in expiredMessages) {
      await _deleteMessage(message);
    }
  }

  /// Schedule message deletion for disappearing messages
  void _scheduleMessageDeletion(MessageModel message) {
    if (!message.isDisappearing) return;

    // For snaps, delete immediately after all participants have viewed
    if (message.type == MessageType.snap) {
      Timer(const Duration(seconds: 1), () => _deleteMessage(message));
    }
    // For other disappearing messages, wait until expiration
    else if (message.expiresAt != null) {
      final delay = message.expiresAt!.difference(DateTime.now());
      if (delay.isNegative) {
        _deleteMessage(message);
      } else {
        Timer(delay, () => _deleteMessage(message));
      }
    }
  }

  /// Delete a message from Firestore and Storage
  Future<void> _deleteMessage(MessageModel message) async {
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
      await initializeIsar();
      if (_isar != null) {
        await _isar!.writeTxn(() async {
          await _isar!.cachedMessages
              .where()
              .messageIdEqualTo(message.id)
              .deleteAll();
        });
      }
    } catch (e) {
      ErrorHandler.logError('delete message', e);
    }
  }

  /// Clear local cache
  Future<void> clearLocalCache() async {
    try {
      await initializeIsar();
      if (_isar == null) return;

      await _isar!.writeTxn(() async {
        await _isar!.cachedConversations.clear();
        await _isar!.cachedMessages.clear();
      });
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
} 