/// Conversations state notifier for managing messaging state.
/// 
/// This notifier handles real-time conversation updates and provides
/// fallback to locally cached data when offline.

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'conversation_model.dart';
import 'messaging_repository.dart';
import '../../../common/utils/error_handler.dart';
import '../../auth/auth.dart';

/// State class for conversations
class ConversationsState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? error;
  final bool isFromCache;

  const ConversationsState({
    required this.conversations,
    this.isLoading = false,
    this.error,
    this.isFromCache = false,
  });

  ConversationsState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? error,
    bool? isFromCache,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

/// Conversations state notifier
class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final MessagingRepository _repository;
  StreamSubscription<List<ConversationModel>>? _conversationsSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ConversationsNotifier(this._repository) 
      : super(const ConversationsState(conversations: [])) {
    _initializeConversations();
    _setupConnectivityListener();
  }

  /// Initialize conversations with real-time updates or cached data
  Future<void> _initializeConversations() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if user is authenticated first
      if (_repository.currentUserId == null) {
        debugPrint('User not authenticated - cannot load conversations');
        state = state.copyWith(
          isLoading: false,
          error: 'Please sign in to view conversations',
          conversations: [],
        );
        return;
      }

      // Test Firestore connectivity first
      debugPrint('Testing Firestore connectivity...');
      final canConnectToFirestore = await _repository.testFirestoreConnectivity();
      
      if (canConnectToFirestore) {
        // Skip connectivity checks - always try real-time first
        // This is more reliable than connectivity detection in emulators
        debugPrint('Firestore connectivity OK - attempting real-time conversations stream...');
        _startConversationsStream();
        
        // Give it a moment to connect
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        // Firestore is not accessible, use cache
        debugPrint('Firestore not accessible, loading cached conversations');
        await _loadCachedConversations();
        
        state = state.copyWith(
          isLoading: false,
          error: 'Using cached data - server unavailable',
          isFromCache: true,
        );
      }
      
    } catch (e) {
      ErrorHandler.logError('initialize conversations', e);
      
      // If real-time fails, fall back to cache
      debugPrint('Real-time connection failed, loading cached conversations');
      await _loadCachedConversations();
      
      if (state.conversations.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load conversations: ${e.toString()}',
        );
      }
    }
  }

  /// Start real-time conversations stream
  void _startConversationsStream() {
    _conversationsSubscription?.cancel();
    
    _conversationsSubscription = _repository
        .getConversationsStream()
        .listen(
          (conversations) {
            state = state.copyWith(
              conversations: conversations,
              isLoading: false,
              error: null,
              isFromCache: false,
            );
            debugPrint('Successfully connected to real-time conversations stream');
          },
          onError: (error) {
            ErrorHandler.logError('conversations stream error', error);
            
            // Check if this is a network/permission error vs a real failure
            final errorString = error.toString().toLowerCase();
            final isNetworkError = errorString.contains('network') || 
                                 errorString.contains('host') ||
                                 errorString.contains('permission') ||
                                 errorString.contains('denied');
            
            if (isNetworkError) {
              // For network errors, try cache fallback
              debugPrint('Network error detected, falling back to cached conversations');
              _loadCachedConversations().then((_) {
                if (state.conversations.isEmpty) {
                  state = state.copyWith(
                    isLoading: false,
                    error: 'No network connection. Please check your internet.',
                    isFromCache: true,
                  );
                } else {
                  state = state.copyWith(
                    isLoading: false,
                    error: 'Using cached data - network unavailable',
                    isFromCache: true,
                  );
                }
              });
            } else {
              // For other errors, just show error but keep trying
              state = state.copyWith(
                isLoading: false,
                error: 'Connection issues. Retrying...',
              );
              
              // Retry after a delay
              Future.delayed(const Duration(seconds: 5), () {
                if (mounted) {
                  debugPrint('Retrying conversations stream connection...');
                  _startConversationsStream();
                }
              });
            }
          },
        );
  }

  /// Load conversations from local cache
  Future<void> _loadCachedConversations() async {
    try {
      final cachedConversations = await _repository.getCachedConversations();
      
      // Convert cached conversations to conversation models
      final conversations = cachedConversations.map((cached) {
        return ConversationModel(
          id: cached.conversationId,
          participantIds: cached.participantIds,
          participantUsernames: cached.participantUsernames,
          isGroup: cached.isGroup,
          groupName: cached.groupName,
          groupAvatarUrl: cached.groupAvatarUrl,
          lastMessageId: cached.lastMessageId,
          lastMessageContent: cached.lastMessageContent,
          lastMessageSenderId: cached.lastMessageSenderId,
          lastMessageTimestamp: cached.lastMessageTimestamp,
          lastViewedTimestamps: cached.lastViewedTimestamps,
          unreadCounts: cached.unreadCounts,
          createdAt: cached.createdAt,
          updatedAt: cached.updatedAt,
        );
      }).toList();

      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
        error: null,
        isFromCache: true,
      );
    } catch (e) {
      ErrorHandler.logError('load cached conversations', e);
      
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load cached conversations: ${e.toString()}',
      );
    }
  }

  /// Setup connectivity listener to switch between real-time and cached data
  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((connectivityResults) {
      final hasConnectivity = connectivityResults.any((result) => 
        result != ConnectivityResult.none
      );

      // Only try to reconnect if we're currently showing cached data
      // and connectivity is restored
      if (hasConnectivity && state.isFromCache) {
        debugPrint('Connectivity restored - attempting to reconnect to real-time stream');
        _startConversationsStream();
      }
      
      // Don't automatically switch to cache on connectivity loss
      // Let the stream error handler deal with actual connection failures
    });
  }

  /// Create or get a direct conversation
  Future<ConversationModel?> createOrGetDirectConversation({
    required String otherUserId,
    required String otherUsername,
  }) async {
    try {
      final conversation = await _repository.createOrGetDirectConversation(
        otherUserId: otherUserId,
        otherUsername: otherUsername,
      );

      // Update state to include the new conversation if it's not already there
      final existingIndex = state.conversations.indexWhere(
        (conv) => conv.id == conversation.id,
      );

      if (existingIndex == -1) {
        final updatedConversations = [conversation, ...state.conversations];
        state = state.copyWith(conversations: updatedConversations);
      }

      return conversation;
    } catch (e) {
      ErrorHandler.logError('create or get direct conversation', e);
      return null;
    }
  }

  /// Refresh conversations manually
  Future<void> refresh() async {
    await _initializeConversations();
  }

  /// Get conversation by ID
  ConversationModel? getConversationById(String conversationId) {
    try {
      return state.conversations.firstWhere(
        (conv) => conv.id == conversationId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Provider for conversations state
final conversationsProvider = StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  final repository = ref.watch(messagingRepositoryProvider);
  return ConversationsNotifier(repository);
});

/// Provider for getting a specific conversation by ID
final conversationByIdProvider = Provider.family<ConversationModel?, String>((ref, conversationId) {
  final conversationsState = ref.watch(conversationsProvider);
  try {
    return conversationsState.conversations.firstWhere(
      (conv) => conv.id == conversationId,
    );
  } catch (e) {
    return null;
  }
}); 