/// Repository for managing Stories feature data.
///
/// Responsibilities:
/// • Reading friends' stories as a real-time stream.
/// • Uploading new story media to Firebase Storage.
/// • Writing/merging story documents in Firestore.
///
/// The implementation purposefully keeps all Firebase logic behind a single
/// abstraction so the rest of the app remains platform-agnostic.

import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:async/async.dart';

import 'story_model.dart';

class StoriesRepository {
  StoriesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  /// Current authenticated user ID or `null` if not signed-in.
  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _storiesCol =>
      _firestore.collection('stories');

  /// Stream all stories ordered by most recent update.
  ///
  /// Filtering by `friendIds` avoids downloading the entire collection for
  /// large user bases.
  Stream<List<StoryDocument>> getStoriesStream({required List<String> friendIds}) {
    // Firestore currently has no `whereIn` with list longer than 30, so split.
    if (friendIds.isEmpty) {
      // Return an empty stream quickly.
      return const Stream.empty();
    }

    // Create one stream per chunk due to Firestore limitations.
    final chunks = <List<String>>[];
    const chunkSize = 10; // keeps it small – Firestore limit 10 for arrays
    for (var i = 0; i < friendIds.length; i += chunkSize) {
      chunks.add(friendIds.sublist(i, i + chunkSize > friendIds.length ? friendIds.length : i + chunkSize));
    }

    final streams = chunks.map((chunk) {
      return _storiesCol
          .where(FieldPath.documentId, whereIn: chunk)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(StoryDocument.fromDoc).toList());
    });

    // Merge multiple query streams into one list.
    return streams.length == 1
        ? streams.first
        : StreamZip<List<StoryDocument>>(streams).map((listOfLists) =>
            listOfLists.expand((e) => e).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
  }

  /// Upload a new [file] to Storage and append it to the current user's story.
  /// Returns the uploaded [StoryMedia] instance for convenience.
  Future<StoryMedia> addStory({
    required File file,
    required String type, // 'photo' | 'video'
    int? duration,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Must be signed-in to add a story');

    // Generate unique IDs.
    final mediaId = const Uuid().v4();
    final ext = p.extension(file.path);

    // Storage path – stories/{uid}/{mediaId}{ext}
    final storageRef = _storage.ref().child('stories').child(uid).child('$mediaId$ext');

    // Upload.
    await storageRef.putFile(file);
    final url = await storageRef.getDownloadURL();

    final media = StoryMedia(
      id: mediaId,
      url: url,
      type: type,
      postedAt: DateTime.now().toUtc(),
      duration: duration,
    );

    // Update Firestore with `arrayUnion` & updatedAt.
    await _storiesCol.doc(uid).set({
      'media': FieldValue.arrayUnion([media.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return media;
  }
} 