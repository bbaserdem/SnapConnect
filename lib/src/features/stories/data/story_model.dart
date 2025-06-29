/// Story data model definitions for Firestore serialization.
///
/// A single story item (photo or video) is represented by [StoryMedia].
/// Documents are stored under the `stories/{userId}` path in Firestore.
/// The document schema matches the following structure:
///
/// ```json
/// {
///   "media": [
///     {
///       "id": "<uuid>",
///       "url": "https://...",
///       "type": "photo" | "video",
///       "postedAt": <Timestamp>,
///       "duration": 10 // optional – seconds to display (images ignored)
///     }
///   ],
///   "updatedAt": <Timestamp>
/// }
/// ```
///
/// We avoid `enum`s in favour of simple string values to keep the schema
/// flexible and Firestore-friendly.

import 'package:cloud_firestore/cloud_firestore.dart';

/// Primitive media type strings.
class StoryMediaType {
  StoryMediaType._();

  static const String photo = 'photo';
  static const String video = 'video';

  /// Validate that [value] is a supported type.
  static bool isValid(String value) => value == photo || value == video;
}

/// Model representing a single photo or video inside a story.
class StoryMedia {
  final String id;
  final String url;
  final String type; // 'photo' or 'video'
  final DateTime postedAt;
  final int? duration; // seconds – only relevant for photos
  final List<String> tags; // optional list of tags for this media

  const StoryMedia({
    required this.id,
    required this.url,
    required this.type,
    required this.postedAt,
    this.duration,
    this.tags = const [],
  });

  /// Create [StoryMedia] from Firestore map.
  factory StoryMedia.fromMap(Map<String, dynamic> map) {
    return StoryMedia(
      id: map['id'] as String,
      url: map['url'] as String,
      type: map['type'] as String,
      postedAt: (map['postedAt'] as Timestamp).toDate(),
      duration: map['duration'] as int?,
      tags: List<String>.from(map['tags'] as List? ?? const []),
    );
  }

  /// Convert a [StoryMedia] instance to a Firestore-friendly map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'url': url,
        'type': type,
        'postedAt': Timestamp.fromDate(postedAt),
        if (duration != null) 'duration': duration,
        if (tags.isNotEmpty) 'tags': tags,
      };
}

/// Firestore document containing all active story media for a user.
class StoryDocument {
  final String userId;
  final List<StoryMedia> media; // ordered by postedAt ascending
  final DateTime updatedAt;

  const StoryDocument({
    required this.userId,
    required this.media,
    required this.updatedAt,
  });

  /// Construct from Firestore [doc].
  factory StoryDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final mediaList = (data['media'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>()
        .map(StoryMedia.fromMap)
        .toList()
      ..sort((a, b) => a.postedAt.compareTo(b.postedAt));

    return StoryDocument(
      userId: doc.id,
      media: mediaList,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Serialize back to Firestore map.
  Map<String, dynamic> toMap() => {
        'media': media.map((e) => e.toMap()).toList(),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
} 