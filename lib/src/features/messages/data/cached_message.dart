/// Cached message model for local Isar database storage.
/// 
/// This model is used to cache message data locally for faster
/// loads and basic offline access.

import 'package:isar/isar.dart';

part 'cached_message.g.dart';

/// Message type enumeration for Isar
enum CachedMessageType {
  text,
  snap,
  image,
  video,
}

@collection
class CachedMessage {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String messageId;

  @Index()
  late String conversationId;

  late String senderId;

  late String senderUsername;

  @Enumerated(EnumType.name)
  late CachedMessageType type;

  String? content;

  String? mediaUrl;

  String? thumbnailUrl;

  int? duration;

  @Index()
  late DateTime sentAt;

  late List<String> viewedBy;

  DateTime? expiresAt;

  late bool isGroupMessage;

  CachedMessage();

  /// Create from MessageModel
  CachedMessage.fromMessageModel(dynamic messageModel) {
    messageId = messageModel.id;
    conversationId = messageModel.conversationId;
    senderId = messageModel.senderId;
    senderUsername = messageModel.senderUsername;
    type = _convertMessageType(messageModel.type);
    content = messageModel.content;
    mediaUrl = messageModel.mediaUrl;
    thumbnailUrl = messageModel.thumbnailUrl;
    duration = messageModel.duration;
    sentAt = messageModel.sentAt;
    viewedBy = messageModel.viewedBy;
    expiresAt = messageModel.expiresAt;
    isGroupMessage = messageModel.isGroupMessage;
  }

  /// Convert MessageType to CachedMessageType
  static CachedMessageType _convertMessageType(dynamic messageType) {
    switch (messageType.toString().split('.').last) {
      case 'text':
        return CachedMessageType.text;
      case 'snap':
        return CachedMessageType.snap;
      case 'image':
        return CachedMessageType.image;
      case 'video':
        return CachedMessageType.video;
      default:
        return CachedMessageType.text;
    }
  }

  /// Check if the message has been viewed by a specific user
  bool hasBeenViewedBy(String userId) {
    return viewedBy.contains(userId);
  }

  /// Check if the message has expired and should be deleted
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if this is a media message (snap, image, or video)
  bool get isMediaMessage {
    return type == CachedMessageType.snap || 
           type == CachedMessageType.image || 
           type == CachedMessageType.video;
  }

  /// Check if this is a disappearing message
  bool get isDisappearing {
    return type == CachedMessageType.snap || expiresAt != null;
  }
} 