/// Riverpod StateNotifier for managing the Friends feature.
///
/// The notifier exposes the following asynchronous streams as plain state:
///   • `acceptedIds`: list of userIds for established friends
///   • `incoming`: list of incoming [FriendDoc] requests
///   • `outgoing`: list of outgoing requests
///
/// The provider listens to underlying Firestore streams and merges the
/// results into a single immutable [FriendsState] to simplify UI code.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/error_handler.dart';
import '../../auth/auth.dart';
import 'friends_repository.dart';
import 'friend_model.dart';

class FriendsState {
  final List<String> acceptedIds;
  final List<FriendDoc> incoming;
  final List<FriendDoc> outgoing;
  final bool isLoading;
  final String? error;

  const FriendsState({
    this.acceptedIds = const [],
    this.incoming = const [],
    this.outgoing = const [],
    this.isLoading = false,
    this.error,
  });

  FriendsState copyWith({
    List<String>? acceptedIds,
    List<FriendDoc>? incoming,
    List<FriendDoc>? outgoing,
    bool? isLoading,
    String? error,
  }) {
    return FriendsState(
      acceptedIds: acceptedIds ?? this.acceptedIds,
      incoming: incoming ?? this.incoming,
      outgoing: outgoing ?? this.outgoing,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class FriendsNotifier extends StateNotifier<FriendsState> {
  FriendsNotifier(this._repo, {required String? uid}) : super(const FriendsState()) {
    _init(uid);
  }

  final FriendsRepository _repo;

  StreamSubscription<List<String>>? _acceptedSub;
  StreamSubscription<List<FriendDoc>>? _incomingSub;
  StreamSubscription<List<FriendDoc>>? _outgoingSub;

  Future<void> _init(String? uid) async {
    if (uid == null) {
      state = state.copyWith(error: 'Please sign in to manage friends');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    _acceptedSub = _repo
        .acceptedFriendIdsStream(uid: uid)
        .listen(
      (ids) => state = state.copyWith(acceptedIds: ids, isLoading: false),
      onError: (err) {
        ErrorHandler.logError('accepted friends stream', err);
        state = state.copyWith(isLoading: false, error: 'Failed to load friends');
      },
    );

    _incomingSub = _repo
        .incomingRequestsStream(uid: uid)
        .listen(
      (docs) => state = state.copyWith(incoming: docs),
      onError: (err) => ErrorHandler.logError('incoming requests stream', err),
    );

    _outgoingSub = _repo
        .outgoingRequestsStream(uid: uid)
        .listen(
      (docs) => state = state.copyWith(outgoing: docs),
      onError: (err) => ErrorHandler.logError('outgoing requests stream', err),
    );
  }

  /// Proxy methods to repository.
  Future<void> sendRequest(String targetUid) => _repo.sendFriendRequest(targetUid);

  Future<void> acceptRequest(String requesterUid) => _repo.acceptFriendRequest(requesterUid);

  Future<void> removeRelationship(String otherUid) => _repo.removeFriendRelationship(otherUid);

  @override
  void dispose() {
    _acceptedSub?.cancel();
    _incomingSub?.cancel();
    _outgoingSub?.cancel();
    super.dispose();
  }
}

/// Providers
final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepository();
});

final friendsProvider = StateNotifierProvider<FriendsNotifier, FriendsState>((ref) {
  final repo = ref.watch(friendsRepositoryProvider);
  final user = ref.watch(authUserProvider).valueOrNull;
  return FriendsNotifier(repo, uid: user?.uid);
});

/// Convenience provider exposing accepted friend ids only.
final acceptedFriendIdsProvider = Provider<List<String>>((ref) {
  return ref.watch(friendsProvider).acceptedIds;
}); 