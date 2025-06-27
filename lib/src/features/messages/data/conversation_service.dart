/// Firestore conversation helper service.
///
/// Encapsulates all operations that modify or create conversation documents so
/// that `MessagingRepository` stays focused on message-level logic.

import 'package:cloud_firestore/cloud_firestore.dart' as ff;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../../common/utils/error_handler.dart';
import 'conversation_model.dart';

class ConversationService {
  ConversationService({required this.firestore, required this.auth});

  final ff.FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final _uuid = const Uuid();

  /// Convenience getter for current user id.
  String? get _uid => auth.currentUser?.uid;

  /* ---------------------------------------------------------------------- */
  /// Create or fetch a direct conversation between the current user and
  /// [otherUserId].
  Future<ConversationModel> createOrGetDirectConversation({
    required String otherUserId,
    required String otherUsername,
  }) async {
    final userId = _uid;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final conversationId =
          ConversationModel.generateDirectConversationId(userId, otherUserId);

      // Check if conversation already exists
      final existingDoc =
          await firestore.collection('conversations').doc(conversationId).get();
      if (existingDoc.exists) {
        return ConversationModel.fromFirestore(existingDoc);
      }

      // Fetch own username
      final currentUserDoc = await firestore.collection('users').doc(userId).get();
      final currentUsername =
          currentUserDoc.data()?['username'] as String? ?? 'Unknown';

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
      ErrorHandler.logError('create/get direct conversation', e);
      rethrow;
    }
  }

  /* ---------------------------------------------------------------------- */
  /// Update the conversation document's last-message metadata.
  Future<void> updateLastMessage({
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

  /* ---------------------------------------------------------------------- */
  /// Increment unread counts for all participants except [senderId].
  Future<void> incrementUnreadCounts(String conversationId, String senderId) async {
    await firestore.runTransaction((txn) async {
      final convRef = firestore.collection('conversations').doc(conversationId);
      final snapshot = await txn.get(convRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentCounts = Map<String, dynamic>.from(data['unreadCounts'] ?? {});
      for (final uid in (data['participantIds'] as List)) {
        if (uid == senderId) continue;
        final current = (currentCounts[uid] as int?) ?? 0;
        currentCounts[uid] = current + 1;
      }
      txn.update(convRef, {
        'unreadCounts': currentCounts,
      });
    });
  }

  /* ---------------------------------------------------------------------- */
  /// Create a group conversation with the specified [participantIds].
  Future<ConversationModel> createGroupConversation({
    required String groupName,
    required List<String> participantIds,
    required Map<String, String> participantUsernames,
  }) async {
    final userId = _uid;
    if (userId == null) throw Exception('User not authenticated');

    final uniqueIds = <String>{...participantIds, userId}.toList();
    if (uniqueIds.length < 2) {
      throw Exception('Group must contain at least two members');
    }
    if (uniqueIds.length > 10) {
      throw Exception('Group can contain at most 10 participants');
    }

    // Ensure usernames map contains all ids
    final usernames = Map<String, String>.from(participantUsernames);
    if (!usernames.containsKey(userId)) {
      final doc = await firestore.collection('users').doc(userId).get();
      usernames[userId] = doc.data()?['username'] as String? ?? 'Unknown';
    }
    for (final id in uniqueIds) {
      usernames[id] = usernames[id] ?? 'Unknown';
    }

    final conversationId = _uuid.v4();
    final now = DateTime.now();

    final conversation = ConversationModel(
      id: conversationId,
      participantIds: uniqueIds,
      participantUsernames: usernames,
      isGroup: true,
      groupName: groupName.trim(),
      lastViewedTimestamps: {for (var id in uniqueIds) id: now},
      unreadCounts: {for (var id in uniqueIds) id: 0},
      createdAt: now,
      updatedAt: now,
      deletedFor: [],
    );

    await firestore.collection('conversations').doc(conversationId).set(conversation.toFirestore());
    return conversation;
  }

  /* ---------------------------------------------------------------------- */
  /// Current user leaves (hides) a conversation.
  Future<void> leaveConversation(String conversationId) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not authenticated');
    try {
      await firestore.collection('conversations').doc(conversationId).update({
        'deletedFor': ff.FieldValue.arrayUnion([uid]),
        'updatedAt': ff.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ErrorHandler.logError('leave conversation', e);
      rethrow;
    }
  }
} 