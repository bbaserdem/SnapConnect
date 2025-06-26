// Messaging providers for state management with Riverpod.
//
// This file contains all providers for conversations, messages,
// and messaging-related state management.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../repositories/messages_repository.dart';
import '../../../auth/auth.dart';

/// Provider for conversations list stream
final conversationsProvider = StreamProvider<List<ConversationModel>>((ref) {
  final messagesRepository = ref.watch(messagesRepositoryProvider);
  final authUser = ref.watch(authUserProvider).value;
  
  if (authUser == null) {
    return Stream.value([]);
  }
  
  return messagesRepository.getConversationsStream(authUser.uid);
});

/// Provider for messages in a specific conversation
final messagesProvider = StreamProvider.family<List<MessageModel>, String>(
  (ref, conversationId) {
    final messagesRepository = ref.watch(messagesRepositoryProvider);
    final authUser = ref.watch(authUserProvider).value;
    
    if (authUser == null) {
      return Stream.value([]);
    }
    
    return messagesRepository.getMessagesStream(conversationId, authUser.uid);
  },
);

/// Provider for user search results
final userSearchProvider = StateNotifierProvider<UserSearchNotifier, UserSearchState>(
  (ref) => UserSearchNotifier(ref.watch(messagesRepositoryProvider)),
);

/// State for user search
class UserSearchState {
  final List<UserModel> users;
  final bool isLoading;
  final String? error;
  final String query;

  const UserSearchState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  UserSearchState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return UserSearchState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }
}

/// Notifier for user search functionality
class UserSearchNotifier extends StateNotifier<UserSearchState> {
  final MessagesRepository _messagesRepository;

  UserSearchNotifier(this._messagesRepository) : super(const UserSearchState());

  /// Search for users by username
  Future<void> searchUsers(String query, String currentUserId) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(users: [], query: query);
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: query);

    try {
      final users = await _messagesRepository.searchUsers(query, currentUserId);
      state = state.copyWith(
        users: users,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear search results
  void clearSearch() {
    state = const UserSearchState();
  }
}

/// Provider for message sending state
final messageSendingProvider = StateNotifierProvider<MessageSendingNotifier, MessageSendingState>(
  (ref) => MessageSendingNotifier(ref.watch(messagesRepositoryProvider)),
);

/// State for message sending
class MessageSendingState {
  final bool isSending;
  final String? error;

  const MessageSendingState({
    this.isSending = false,
    this.error,
  });

  MessageSendingState copyWith({
    bool? isSending,
    String? error,
  }) {
    return MessageSendingState(
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

/// Notifier for message sending operations
class MessageSendingNotifier extends StateNotifier<MessageSendingState> {
  final MessagesRepository _messagesRepository;

  MessageSendingNotifier(this._messagesRepository) : super(const MessageSendingState());

  /// Send a text message
  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String senderUsername,
    required String content,
  }) async {
    state = state.copyWith(isSending: true, error: null);

    try {
      await _messagesRepository.sendTextMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderUsername: senderUsername,
        content: content,
      );
      
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
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
    state = state.copyWith(isSending: true, error: null);

    try {
      await _messagesRepository.sendSnapMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderUsername: senderUsername,
        localFilePath: localFilePath,
        mediaType: mediaType,
        duration: duration,
        width: width,
        height: height,
      );
      
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for conversation creation
final conversationCreationProvider = StateNotifierProvider<ConversationCreationNotifier, ConversationCreationState>(
  (ref) => ConversationCreationNotifier(ref.watch(messagesRepositoryProvider)),
);

/// State for conversation creation
class ConversationCreationState {
  final bool isCreating;
  final String? error;
  final String? createdConversationId;

  const ConversationCreationState({
    this.isCreating = false,
    this.error,
    this.createdConversationId,
  });

  ConversationCreationState copyWith({
    bool? isCreating,
    String? error,
    String? createdConversationId,
  }) {
    return ConversationCreationState(
      isCreating: isCreating ?? this.isCreating,
      error: error,
      createdConversationId: createdConversationId,
    );
  }
}

/// Notifier for conversation creation
class ConversationCreationNotifier extends StateNotifier<ConversationCreationState> {
  final MessagesRepository _messagesRepository;

  ConversationCreationNotifier(this._messagesRepository) : super(const ConversationCreationState());

  /// Create a direct conversation
  Future<String?> createDirectConversation({
    required String currentUserId,
    required String otherUserId,
    required String currentUsername,
    required String otherUsername,
  }) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      final conversationId = await _messagesRepository.createDirectConversation(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
        currentUsername: currentUsername,
        otherUsername: otherUsername,
      );
      
      state = state.copyWith(
        isCreating: false,
        createdConversationId: conversationId,
      );
      
      return conversationId;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Create a group conversation
  Future<String?> createGroupConversation({
    required String creatorId,
    required String creatorUsername,
    required List<String> participantIds,
    required Map<String, String> participantUsernames,
    required String groupName,
  }) async {
    state = state.copyWith(isCreating: true, error: null);

    try {
      final conversationId = await _messagesRepository.createGroupConversation(
        creatorId: creatorId,
        creatorUsername: creatorUsername,
        participantIds: participantIds,
        participantUsernames: participantUsernames,
        groupName: groupName,
      );
      
      state = state.copyWith(
        isCreating: false,
        createdConversationId: conversationId,
      );
      
      return conversationId;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Clear state
  void clear() {
    state = const ConversationCreationState();
  }
} 