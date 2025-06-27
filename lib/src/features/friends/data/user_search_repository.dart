/// Repository for searching users by username prefix.
///
/// Uses a Firestore range query (`startAt` / `endAt`) on the `username`
/// field (which is stored lowercase) to fetch up to [limit] matching users.
///
/// NOTE: There is no built-in full-text search; this is simple prefix
/// matching which is enough for the add-friend flow.

import 'package:cloud_firestore/cloud_firestore.dart';

class UserSearchResult {
  final String uid;
  final String username;
  final String displayName;

  UserSearchResult({required this.uid, required this.username, required this.displayName});
}

class UserSearchRepository {
  UserSearchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<UserSearchResult>> search(String query, {int limit = 10}) async {
    final normalized = query.toLowerCase().trim();
    if (normalized.isEmpty) return [];

    final end = '${normalized}\uf8ff';
    final snapshot = await _firestore
        .collection('users')
        .orderBy('username')
        .startAt([normalized])
        .endAt([end])
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserSearchResult(
        uid: doc.id,
        username: data['username'] as String? ?? '',
        displayName: data['display_name'] as String? ?? '',
      );
    }).toList();
  }
} 