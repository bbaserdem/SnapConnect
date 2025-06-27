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

  Future<void> _init() async {
    // Wait until the auth provider resolves.
    final user = await _ref.read(authUserProvider.future);
    if (user == null) {
      state = state.copyWith(error: 'Please sign in to view stories');
      return;
    }

    _listenToStories();
    _setupConnectivity();
  }

  void _listenToStories() {
    state = state.copyWith(isLoading: true, error: null);

    // TODO: Replace with real friends list once friend feature arrives.
    // For now, fetch everyone including current user.
    final uid = _repository.currentUserId;
    final friendIds = [uid!];

    _storiesSub?.cancel();
    _storiesSub = _repository
        .getStoriesStream(friendIds: friendIds)
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
        _listenToStories(); // retry
      }
    });
  }

  @override
  void dispose() {
    _storiesSub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}

/// Providers
final storiesRepositoryProvider = Provider<StoriesRepository>((ref) {
  return StoriesRepository();
});

final storiesProvider = StateNotifierProvider<StoriesNotifier, StoriesState>((ref) {
  final repo = ref.watch(storiesRepositoryProvider);
  return StoriesNotifier(repo, ref);
}); 