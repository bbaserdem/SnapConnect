/// Riverpod StateNotifier for managing Stories state.
///
/// Listens to the real-time stream provided by [StoriesRepository] and exposes
/// loading / error states. If connectivity fails, the notifier will expose an
/// error yet keep previously loaded data to ensure a graceful UX.

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/error_handler.dart';
import '../../auth/auth.dart';
import '../../friends/data/friends_notifier.dart';
import 'stories_repository.dart';
import 'story_model.dart';

/// Immutable Stories UI state.
class StoriesState {
  final List<StoryDocument> stories;
  final bool isLoading;
  final String? error;

  const StoriesState({
    required this.stories,
    this.isLoading = false,
    this.error,
  });

  StoriesState copyWith({
    List<StoryDocument>? stories,
    bool? isLoading,
    String? error,
  }) {
    return StoriesState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StoriesNotifier extends StateNotifier<StoriesState> {
  StoriesNotifier(this._repository, this._ref) : super(const StoriesState(stories: [])) {
    _init();
  }

  final StoriesRepository _repository;
  final Ref _ref;

  StreamSubscription<List<StoryDocument>>? _storiesSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  ProviderSubscription<List<String>>? _friendIdsSub;

  Future<void> _init() async {
    // Wait until the auth provider resolves.
    final user = await _ref.read(authUserProvider.future);
    if (user == null) {
      state = state.copyWith(error: 'Please sign in to view stories');
      return;
    }

    // Combine current user's uid with accepted friend ids from provider.
    final currentUid = user.uid;

    _friendIdsSub = _ref.listen<List<String>>(acceptedFriendIdsProvider, (prev, next) {
      // Ensure we always include current user's own uid.
      final ids = {currentUid, ...next}.toList();
      _listenToStories(ids);
    }, fireImmediately: true);

    _setupConnectivity();
  }

  void _listenToStories(List<String> visibleIds) {
    state = state.copyWith(isLoading: true, error: null);

    if (visibleIds.isEmpty) {
      // No friends yet – show nothing.
      state = state.copyWith(stories: [], isLoading: false);
      _storiesSub?.cancel();
      return;
    }

    _storiesSub?.cancel();
    _storiesSub = _repository
        .getStoriesStream(friendIds: visibleIds)
        .listen(
      (stories) {
        state = state.copyWith(stories: stories, isLoading: false, error: null);
      },
      onError: (err) {
        ErrorHandler.logError('stories stream', err);
        state = state.copyWith(isLoading: false, error: 'Failed to load stories');
      },
    );
  }

  void _setupConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasNetwork = results.any((r) => r != ConnectivityResult.none);
      if (hasNetwork && state.error != null) {
        _listenToStories([_repository.currentUserId!]); // retry
      }
    });
  }

  @override
  void dispose() {
    _storiesSub?.cancel();
    _connectivitySub?.cancel();
    _friendIdsSub?.close();
    super.dispose();
  }
}

/// Providers
final storiesRepositoryProvider = Provider<StoriesRepository>((ref) {
  return StoriesRepository();
});

final storiesProvider = StateNotifierProvider.autoDispose<StoriesNotifier, StoriesState>((ref) {
  final repo = ref.watch(storiesRepositoryProvider);
  return StoriesNotifier(repo, ref);
}); 