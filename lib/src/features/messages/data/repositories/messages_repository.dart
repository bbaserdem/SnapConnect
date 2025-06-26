// Messages repository for handling real-time messaging operations.
//
// This repository manages conversations, messages, and snap uploads
// using Firestore for real-time synchronization.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../../../auth/data/user_model.dart';
import '../../../../common/utils/error_handler.dart';

/// Provider for the MessagesRepository
final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

/// Repository for messaging operations
class MessagesRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  MessagesRepository({
    required this.firestore,
    required this.storage,
  });

  // === Conversation Operations ===

  /// Get conversations for a user as a stream
  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    try {
      return firestore
          .collection('conversations')
          .where('participants', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      ErrorHandler.logError(
        'get conversations stream',
        e,
        additionalInfo: {'userId': userId},
      );
      return Stream.error('Failed to load conversations');
    }
  }

  /// Create a new direct conversation
  Future<String> createDirectConversation({
    required String currentUserId,
    required String otherUserId,
    required String currentUsername,
    required String otherUsername,
  }) async {
    try {
      // Check if conversation already exists
      final existingConversation = await firestore
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .where('type', isEqualTo: 'direct')
          .get();

      for (final doc in existingConversation.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        if (participants.contains(otherUserId) && participants.length == 2) {
          return doc.id; // Return existing conversation
        }
      }

      // Create new conversation
      final conversationRef = firestore.collection('conversations').doc();
      
      final conversation = ConversationModel(
        conversationId: conversationRef.id,
        participants: [currentUserId, otherUserId],
        participantUsernames: {
          currentUserId: currentUsername,
          otherUserId: otherUsername,
        },
        type: ConversationType.direct,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await conversationRef.set(conversation.toFirestore());

      ErrorHandler.logSuccess(
        'create direct conversation',
        additionalInfo: {
          'conversationId': conversationRef.id,
          'participants': [currentUserId, otherUserId],
        },
      );

      return conversationRef.id;
    } catch (e) {
      ErrorHandler.logError(
        'create direct conversation',
        e,
        additionalInfo: {
          'currentUserId': currentUserId,
          'otherUserId': otherUserId,
        },
      );
      throw ErrorHandler.createException(
        'Failed to create conversation. Please try again.',
        operation: 'create conversation',
      );
    }
  }

  /// Create a new group conversation
  Future<String> createGroupConversation({
    required String creatorId,
    required String creatorUsername,
    required List<String> participantIds,
    required Map<String, String> participantUsernames,
    required String groupName,
  }) async {
    try {
      final conversationRef = firestore.collection('conversations').doc();
      
      final allParticipants = [creatorId, ...participantIds];
      final allUsernames = {
        creatorId: creatorUsername,
        ...participantUsernames,
      };

      final conversation = ConversationModel(
        conversationId: conversationRef.id,
        participants: allParticipants,
        participantUsernames: allUsernames,
        type: ConversationType.group,
        groupName: groupName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await conversationRef.set(conversation.toFirestore());

      ErrorHandler.logSuccess(
        'create group conversation',
        additionalInfo: {
          'conversationId': conversationRef.id,
          'participantCount': allParticipants.length,
          'groupName': groupName,
        },
      );

      return conversationRef.id;
    } catch (e) {
      ErrorHandler.logError(
        'create group conversation',
        e,
        additionalInfo: {
          'creatorId': creatorId,
          'participantCount': participantIds.length,
        },
      );
      throw ErrorHandler.createException(
        'Failed to create group chat. Please try again.',
        operation: 'create group conversation',
      );
    }
  }

  // === Message Operations ===

  /// Get messages for a conversation as a stream
  Stream<List<MessageModel>> getMessagesStream(
    String conversationId, 
    String currentUserId,
  ) {
    try {
      return firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(50) // Load 50 most recent messages
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc, currentUserId))
            .toList();
      });
    } catch (e) {
      ErrorHandler.logError(
        'get messages stream',
        e,
        additionalInfo: {
          'conversationId': conversationId,
          'currentUserId': currentUserId,
        },
      );
      return Stream.error('Failed to load messages');
    }
  }

  /// Send a text message
  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String senderUsername,
    required String content,
  }) async {
    try {
      final messageRef = firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();

      final message = MessageModel(
        messageId: messageRef.id,
        conversationId: conversationId,
        senderId: senderId,
        senderUsername: senderUsername,
        content: content,
        timestamp: DateTime.now(),
        viewedBy: {senderId: DateTime.now()}, // Mark as read by sender
        messageType: MessageType.text,
      );

      // Send message
      await messageRef.set(message.toFirestore());

      // Update conversation last message
      await _updateConversationLastMessage(
        conversationId: conversationId,
        lastMessage: message,
      );

      ErrorHandler.logSuccess(
        'send text message',
        additionalInfo: {
          'conversationId': conversationId,
          'messageId': messageRef.id,
          'contentLength': content.length,
        },
      );
    } catch (e) {
      ErrorHandler.logError(
        'send text message',
        e,
        additionalInfo: {
          'conversationId': conversationId,
          'senderId': senderId,
        },
      );
      throw ErrorHandler.createException(
        'Failed to send message. Please try again.',
        operation: 'send text message',
      );
    }
  }

  /// Send a snap message
  Future<void> sendSnapMessage({
    required String conversationId,
    required String senderId,
    required String senderUsername,
    required String localFilePath,
    required SnapMediaType mediaType,
    required int duration,
    int? width,
    int? height,
  }) async {
    try {
      final messageRef = firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();

      // Upload file to Firebase Storage
      final storagePath = 'snaps/$conversationId/${messageRef.id}';
      final file = File(localFilePath);
      
      final uploadTask = storage.ref(storagePath).putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Create message
      final message = MessageModel(
        messageId: messageRef.id,
        conversationId: conversationId,
        senderId: senderId,
        senderUsername: senderUsername,
        snapRef: storagePath,
        snapDuration: duration,
        timestamp: DateTime.now(),
        viewedBy: {senderId: DateTime.now()}, // Mark as read by sender
        messageType: MessageType.snap,
      );

      // Create snap metadata
      final snap = SnapModel(
        snapId: messageRef.id,
        messageId: messageRef.id,
        conversationId: conversationId,
        senderId: senderId,
        storagePath: storagePath,
        downloadUrl: downloadUrl,
        localPath: localFilePath,
        mediaType: mediaType,
        duration: duration,
        createdAt: DateTime.now(),
        fileSizeBytes: await file.length(),
        width: width,
        height: height,
      );

      // Save message and snap metadata
      await Future.wait([
        messageRef.set(message.toFirestore()),
        firestore.collection('snaps').doc(messageRef.id).set(snap.toFirestore()),
      ]);

      // Update conversation last message
      await _updateConversationLastMessage(
        conversationId: conversationId,
        lastMessage: message,
      );

      ErrorHandler.logSuccess(
        'send snap message',
        additionalInfo: {
          'conversationId': conversationId,
          'messageId': messageRef.id,
          'mediaType': mediaType.name,
          'duration': duration,
        },
      );
    } catch (e) {
      ErrorHandler.logError(
        'send snap message',
        e,
        additionalInfo: {
          'conversationId': conversationId,
          'senderId': senderId,
          'mediaType': mediaType.name,
        },
      );
      throw ErrorHandler.createException(
        'Failed to send snap. Please try again.',
        operation: 'send snap message',
      );
    }
  }

  /// Mark message as viewed
  Future<void> markMessageAsViewed({
    required String conversationId,
    required String messageId,
    required String userId,
  }) async {
    try {
      final messageRef = firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId);

      await messageRef.update({
        'viewedBy.$userId': FieldValue.serverTimestamp(),
      });

      // For snap messages, set expiration after first view
      final messageDoc = await messageRef.get();
      if (messageDoc.exists) {
        final data = messageDoc.data()!;
        if (data['messageType'] == 'snap' && 
            !(data['viewedBy'] as Map? ?? {}).containsKey(userId)) {
          await messageRef.update({
            'expiresAt': Timestamp.fromDate(
              DateTime.now().add(const Duration(seconds: 30)),
            ),
          });
        }
      }

      ErrorHandler.logSuccess(
        'mark message as viewed',
        additionalInfo: {
          'conversationId': conversationId,
          'messageId': messageId,
          'userId': userId,
        },
      );
    } catch (e) {
      ErrorHandler.logError(
        'mark message as viewed',
        e,
        additionalInfo: {
          'conversationId': conversationId,
          'messageId': messageId,
          'userId': userId,
        },
      );
      // Don't throw error for marking as read - it's not critical
    }
  }

  /// Delete expired messages
  Future<void> deleteExpiredMessages() async {
    try {
      final now = Timestamp.now();
      
      // Find expired messages
      final expiredQuery = await firestore
          .collectionGroup('messages')
          .where('expiresAt', isLessThan: now)
          .get();

      for (final doc in expiredQuery.docs) {
        final data = doc.data();
        
        // Delete from Storage if it's a snap
        if (data['snapRef'] != null) {
          try {
            await storage.ref(data['snapRef'] as String).delete();
          } catch (e) {
            debugPrint('Failed to delete snap from storage: $e');
          }
        }

        // Delete message document
        await doc.reference.delete();
      }

      if (expiredQuery.docs.isNotEmpty) {
        ErrorHandler.logSuccess(
          'delete expired messages',
          additionalInfo: {'deletedCount': expiredQuery.docs.length},
        );
      }
    } catch (e) {
      ErrorHandler.logError('delete expired messages', e);
      // Don't throw - this is background cleanup
    }
  }

  // === Helper Methods ===

  /// Update conversation's last message
  Future<void> _updateConversationLastMessage({
    required String conversationId,
    required MessageModel lastMessage,
  }) async {
    try {
      await firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': {
          'content': lastMessage.getDisplayContent(),
          'senderId': lastMessage.senderId,
          'type': lastMessage.messageType.name,
        },
        'lastMessageTime': Timestamp.fromDate(lastMessage.timestamp),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ErrorHandler.logError(
        'update conversation last message',
        e,
        additionalInfo: {'conversationId': conversationId},
      );
      // Don't throw - message was sent successfully
    }
  }

  /// Search for users to start conversations with
  Future<List<UserModel>> searchUsers(String query, String currentUserId) async {
    try {
      if (query.trim().isEmpty) return [];

      final queryLower = query.toLowerCase().trim();
      
      // Search by username
      final usernameQuery = await firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: queryLower)
          .where('username', isLessThan: queryLower + '\uf8ff')
          .limit(10)
          .get();

      final users = usernameQuery.docs
          .where((doc) => doc.id != currentUserId) // Exclude current user
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      ErrorHandler.logSuccess(
        'search users',
        additionalInfo: {
          'query': query,
          'resultCount': users.length,
        },
      );

      return users;
    } catch (e) {
      ErrorHandler.logError(
        'search users',
        e,
        additionalInfo: {'query': query},
      );
      throw ErrorHandler.createException(
        'Failed to search users. Please try again.',
        operation: 'search users',
      );
    }
  }
} 