/// Repository abstraction for the Friends feature.
///
/// All reads/writes related to the friends sub-collection go through this
/// class so the rest of the application remains agnostic of the
/// underlying data source (Firestore).
///
/// The repository is intentionally **thin** – it merely orchestrates
/// Firestore calls and leaves higher-level business logic to state
/// notifiers.
///
/// Relationships are stored under `users/{uid}/friends/{friendUid}`. See
/// `friend_model.dart` for the document schema.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'friend_model.dart';

class FriendsRepository {
  FriendsRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Convenience getter for current user id or `null` if signed-out.
  String? get uid => _auth.currentUser?.uid;

  /// Reference to the current user's `friends` sub-collection.
  CollectionReference<Map<String, dynamic>> _friendsCol(String uid) =>
      _firestore.collection('users').doc(uid).collection('friends');

  /// Stream **accepted** friends UIDs for [uid]. Emits an empty list when no
  /// friends are present.
  Stream<List<String>> acceptedFriendIdsStream({required String uid}) {
    return _friendsCol(uid)
        .where('status', isEqualTo: FriendStatus.accepted)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  /// Stream **incoming** friend requests (status == requested) for [uid].
  Stream<List<FriendDoc>> incomingRequestsStream({required String uid}) {
    return _friendsCol(uid)
        .where('status', isEqualTo: FriendStatus.requested)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FriendDoc.fromDoc).toList());
  }

  /// Stream **outgoing** friend requests (status == pending) for [uid].
  Stream<List<FriendDoc>> outgoingRequestsStream({required String uid}) {
    return _friendsCol(uid)
        .where('status', isEqualTo: FriendStatus.pending)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FriendDoc.fromDoc).toList());
  }

  /// Send a friend request from current user to [targetUid].
  Future<void> sendFriendRequest(String targetUid) async {
    final currentUid = uid;
    if (currentUid == null) {
      throw Exception('Must be signed-in to send friend requests');
    }
    if (targetUid == currentUid) {
      throw Exception('You cannot add yourself as a friend');
    }

    final batch = _firestore.batch();

    // Outgoing doc for current user – status pending.
    final now = DateTime.now().toUtc();
    batch.set(
      _friendsCol(currentUid).doc(targetUid),
      FriendDoc(
        friendUid: targetUid,
        status: FriendStatus.pending,
        createdAt: now,
        updatedAt: now,
      ).toMap(),
      SetOptions(merge: true),
    );

    // Incoming doc for target user – status requested.
    batch.set(
      _friendsCol(targetUid).doc(currentUid),
      FriendDoc(
        friendUid: currentUid,
        status: FriendStatus.requested,
        createdAt: now,
        updatedAt: now,
      ).toMap(),
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Accept a friend request **received** from [requesterUid].
  Future<void> acceptFriendRequest(String requesterUid) async {
    final currentUid = uid;
    if (currentUid == null) {
      throw Exception('Must be signed-in to accept friend requests');
    }

    final batch = _firestore.batch();
    final now = DateTime.now().toUtc();

    // Update both docs to accepted.
    batch.update(_friendsCol(currentUid).doc(requesterUid), {
      'status': FriendStatus.accepted,
      'updatedAt': Timestamp.fromDate(now),
    });

    batch.update(_friendsCol(requesterUid).doc(currentUid), {
      'status': FriendStatus.accepted,
      'updatedAt': Timestamp.fromDate(now),
    });

    await batch.commit();
  }

  /// Decline or cancel the friend request between current user and
  /// [otherUid]. Removes both docs.
  Future<void> removeFriendRelationship(String otherUid) async {
    final currentUid = uid;
    if (currentUid == null) {
      throw Exception('Must be signed-in to modify friends');
    }

    final batch = _firestore.batch();
    batch.delete(_friendsCol(currentUid).doc(otherUid));
    batch.delete(_friendsCol(otherUid).doc(currentUid));
    await batch.commit();
  }
} 