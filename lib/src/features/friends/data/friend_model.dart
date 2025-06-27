/// Friend relationship data models for Firestore serialization.
///
/// Each user keeps a `friends` sub-collection storing relationship
/// documents identified by the friend user id. The schema is **flat** to
/// allow efficient look-ups and security rules:
///
/// ```text
/// users/{uid}/friends/{friendUid}
///   ├─ status: "pending" | "accepted"
///   ├─ createdAt: <Timestamp>
///   └─ updatedAt: <Timestamp>
/// ```
///
/// We purposely avoid `enum`s and instead expose simple string constants
/// via [FriendStatus] to keep the collection portable and avoid breaking
/// changes when introducing new states.
///
/// A symmetrical relationship is maintained **client-side** – when user A
/// adds user B, two documents are created:
///  • `users/A/friends/B` with `status = pending` (waiting for B)
///  • `users/B/friends/A` with `status = requested` (incoming request)
///
/// Once user B accepts, both documents are updated to `accepted`.
///
/// Only these three states are required for Phase 1.6.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Primitive friend relationship states.
class FriendStatus {
  FriendStatus._();

  static const String pending = 'pending'; // outbound request awaiting reply
  static const String requested = 'requested'; // inbound request waiting for current user
  static const String accepted = 'accepted'; // mutually accepted friendship

  static bool isValid(String value) =>
      value == pending || value == requested || value == accepted;
}

/// Friend relationship document model.
class FriendDoc {
  final String friendUid;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FriendDoc({
    required this.friendUid,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FriendDoc.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FriendDoc(
      friendUid: doc.id,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
} 