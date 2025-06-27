/// Reactive riverpod provider for username search suggestions.
///
/// The [usernameSearchProvider] is a `FutureProvider.family` that takes the
/// current query string and returns up to 10 `UserSearchResult`s.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_search_repository.dart';

final userSearchRepositoryProvider = Provider<UserSearchRepository>((ref) {
  return UserSearchRepository();
});

final usernameSearchProvider = FutureProvider.autoDispose
    .family<List<UserSearchResult>, String>((ref, query) async {
  final repo = ref.watch(userSearchRepositoryProvider);
  return repo.search(query, limit: 10);
}); 