/// Messaging providers for conversation messages.
/// 
/// This file replaces the previous StateNotifier-based implementation with
/// concise Riverpod providers, dramatically reducing boilerplate while
/// preserving the public API consumed by the UI layer.

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'message_model.dart';
import 'messaging_repository.dart';

/// A [StreamProvider.family] that exposes the live list of messages for the given
/// `conversationId`.
///
/// This replaces the bespoke [MessagesState] + [StateNotifier] implementation,
/// allowing Riverpod to automatically manage loading & error states via
/// [AsyncValue].
final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  final repository = ref.watch(messagingRepositoryProvider);
  return repository.getMessagesStream(conversationId);
});

/// Helper provider used by the UI to send a text message. Keeping it as a
/// separate provider keeps the widget layer free of repository details.
final sendTextMessageProvider = Provider.family<Future<void> Function(String), String>((ref, conversationId) {
  final repository = ref.watch(messagingRepositoryProvider);
  return (content) => repository.sendTextMessage(
        conversationId: conversationId,
        content: content,
      );
});

/// Helper provider used by the UI to send snaps / media messages.
final sendMediaMessageProvider = Provider.family<
    Future<void> Function({
      required String mediaPath,
      required MessageType type,
      required int duration,
      String? thumbnailPath,
    }),
    String>((ref, conversationId) {
  final repository = ref.watch(messagingRepositoryProvider);
  return ({
    required String mediaPath,
    required MessageType type,
    required int duration,
    String? thumbnailPath,
  }) => repository.sendSnapMessage(
        conversationId: conversationId,
        mediaFile: File(mediaPath),
        type: type,
        duration: duration,
        thumbnailFile: thumbnailPath != null ? File(thumbnailPath) : null,
      );
});

/// Marks a message as viewed by the current user. Exposed as a provider so it
/// can be easily injected where necessary.
final markMessageViewedProvider = Provider.family<Future<void> Function(String), String>((ref, conversationId) {
  final repository = ref.watch(messagingRepositoryProvider);
  final currentUserId = repository.currentUserId;
  return (messageId) {
    if (currentUserId == null) return Future.value();
    return repository.markMessageAsViewed(messageId, currentUserId);
  };
}); 