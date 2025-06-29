/// Local cache service encapsulating Isar database access.
///
/// Keeps `MessagingRepository` slim by moving persistence concerns here.
/// Provides convenience methods for reading, writing and clearing cached
/// conversations and messages.

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'cached_conversation.dart';
import 'cached_message.dart';
import 'conversation_model.dart';
import 'message_model.dart';
import '../../../common/utils/error_handler.dart';

class LocalCacheService {
  // Private constructor; use [LocalCacheService()] factory.
  LocalCacheService();

  Isar? _isar;

  /// Ensure the Isar instance is initialised.
  Future<void> _ensureIsar() async {
    if (_isar != null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open([
        CachedConversationSchema,
        CachedMessageSchema,
      ], directory: dir.path);
    } catch (e) {
      // Could not open database; log but do not crash the app.
      ErrorHandler.logError('initialize isar', e);
    }
  }

  /// Cache a batch of [conversations].
  Future<void> cacheConversations(List<ConversationModel> conversations) async {
    await _ensureIsar();
    if (_isar == null) return;

    final cached = conversations
        .map(CachedConversation.fromConversationModel)
        .toList();

    await _isar!.writeTxn(() async {
      await _isar!.cachedConversations.putAllByConversationId(cached);
    });
  }

  /// Cache a batch of [messages].
  Future<void> cacheMessages(List<MessageModel> messages) async {
    await _ensureIsar();
    if (_isar == null) return;

    final cached = messages.map(CachedMessage.fromMessageModel).toList();

    await _isar!.writeTxn(() async {
      await _isar!.cachedMessages.putAllByMessageId(cached);
    });
  }

  /// Get cached conversations sorted by latest message timestamp.
  Future<List<CachedConversation>> getCachedConversations() async {
    await _ensureIsar();
    return _isar?.cachedConversations
            .where()
            .sortByLastMessageTimestampDesc()
            .findAll() ??
        [];
  }

  /// Get cached messages of a conversation.
  Future<List<CachedMessage>> getCachedMessages(String conversationId) async {
    await _ensureIsar();
    return _isar?.cachedMessages
            .where()
            .conversationIdEqualTo(conversationId)
            .sortBySentAtDesc()
            .limit(50)
            .findAll() ??
        [];
  }

  /// Remove all cached rows for a message id.
  Future<void> removeMessageById(String messageId) async {
    await _ensureIsar();
    if (_isar == null) return;
    await _isar!.writeTxn(() async {
      await _isar!.cachedMessages
          .where()
          .messageIdEqualTo(messageId)
          .deleteAll();
    });
  }

  /// Clear all local cache.
  Future<void> clear() async {
    await _ensureIsar();
    if (_isar == null) return;
    await _isar!.writeTxn(() async {
      await _isar!.cachedConversations.clear();
      await _isar!.cachedMessages.clear();
    });
  }
}
