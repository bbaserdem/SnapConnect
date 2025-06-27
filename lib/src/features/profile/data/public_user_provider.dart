/// Public user profile provider.
///
/// Fetches `username` and `display_name` for a given UID from Firestore.
/// Keeps the model lean – any additional public fields can be added later
/// without breaking call-sites.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicUser {
  final String uid;
  final String username;
  final String displayName;

  const PublicUser({required this.uid, required this.username, required this.displayName});
}

/// Fetch once – not real-time. Switch to `doc.snapshots()` if needed.
final publicUserProvider = FutureProvider.family<PublicUser, String>((ref, uid) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final data = doc.data() ?? {};
  return PublicUser(
    uid: uid,
    username: (data['username'] as String?) ?? uid,
    displayName: (data['display_name'] as String?) ?? '',
  );
}); 