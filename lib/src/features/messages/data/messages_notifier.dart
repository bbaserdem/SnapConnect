/// Messages state notifier for managing individual conversation messages.
/// 
/// This notifier handles real-time message updates for a specific conversation
/// and provides functionality to send text and media messages.

import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'message_model.dart';
import 'messaging_repository.dart';
import '../../../common/utils/error_handler.dart';

/// State class for messages in a conversation
class MessagesState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;

  const MessagesState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });

  MessagesState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? error,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Messages state notifier for a specific conversation
class MessagesNotifier extends StateNotifier<MessagesState> {
  final MessagingRepository _repository;
  final String conversationId;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  MessagesNotifier(
    this._repository,
    this.conversationId,
  ) : super(const MessagesState(messages: [])) {
    _initializeMessages();
  }

  /// Initialize messages stream
  Future<void> _initializeMessages() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      debugPrint('Initializing messages stream for conversation: $conversationId');
      
      // Start listening to messages stream
      _messagesSubscription = _repository
          .getMessagesStream(conversationId)
          .listen(
            (messages) {
              debugPrint('Received ${messages.length} messages for conversation $conversationId');
              state = state.copyWith(
                messages: messages,
                isLoading: false,
                error: null,
              );
            },
            onError: (error) {
              debugPrint('Error in messages stream: $error');
              ErrorHandler.logError('messages stream', error);
              state = state.copyWith(
                isLoading: false,
                error: error.toString(),
              );
            },
          );
    } catch (e) {
      debugPrint('Error initializing messages: $e');
      ErrorHandler.logError('initialize messages', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Send a text message
  Future<void> sendTextMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      debugPrint('Sending text message: $content');
      
      await _repository.sendTextMessage(
        conversationId: conversationId,
        content: content.trim(),
      );
      
      debugPrint('Text message sent successfully');
    } catch (e) {
      debugPrint('Error sending text message: $e');
      ErrorHandler.logError('send text message', e);
      
      // Show error but don't update state as the stream will handle it
      state = state.copyWith(error: 'Failed to send message: ${e.toString()}');
      
      // Clear error after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = state.copyWith(error: null);
        }
      });
    }
  }

  /// Send a media message (snap)
  Future<void> sendMediaMessage({
    required String mediaPath,
    required MessageType type,
    required int duration,
    String? thumbnailPath,
  }) async {
    try {
      debugPrint('Sending media message: $type');
      
      await _repository.sendSnapMessage(
        conversationId: conversationId,
        mediaFile: File(mediaPath),
        type: type,
        duration: duration,
        thumbnailFile: thumbnailPath != null ? File(thumbnailPath) : null,
      );
      
      debugPrint('Media message sent successfully');
    } catch (e) {
      debugPrint('Error sending media message: $e');
      ErrorHandler.logError('send media message', e);
      
      state = state.copyWith(error: 'Failed to send media: ${e.toString()}');
      
      // Clear error after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          state = state.copyWith(error: null);
        }
      });
    }
  }

  /// Mark a message as viewed
  Future<void> markMessageAsViewed(String messageId) async {
    try {
      final currentUserId = _repository.currentUserId;
      if (currentUserId == null) return;
      
      await _repository.markMessageAsViewed(messageId, currentUserId);
    } catch (e) {
      debugPrint('Error marking message as viewed: $e');
      ErrorHandler.logError('mark message as viewed', e);
    }
  }

  /// Refresh messages manually
  Future<void> refresh() async {
    await _initializeMessages();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for messages state for a specific conversation
final messagesProvider = StateNotifierProvider.family<MessagesNotifier, MessagesState, String>(
  (ref, conversationId) {
    final repository = ref.watch(messagingRepositoryProvider);
    return MessagesNotifier(repository, conversationId);
  },
);

/// Provider for sending text messages
final sendTextMessageProvider = Provider.family<Future<void> Function(String), String>(
  (ref, conversationId) {
    return (content) => ref.read(messagesProvider(conversationId).notifier).sendTextMessage(content);
  },
);

/// Provider for sending media messages
final sendMediaMessageProvider = Provider.family<
  Future<void> Function({
    required String mediaPath,
    required MessageType type,
    required int duration,
    String? thumbnailPath,
  }), String
>(
  (ref, conversationId) {
    return ({
      required String mediaPath,
      required MessageType type,
      required int duration,
      String? thumbnailPath,
    }) => ref.read(messagesProvider(conversationId).notifier).sendMediaMessage(
      mediaPath: mediaPath,
      type: type,
      duration: duration,
      thumbnailPath: thumbnailPath,
    );
  },
); 