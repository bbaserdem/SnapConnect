# Refactor Plan: Extract ChatMessagesList

This document outlines the steps to extract the message list logic from `chat_screen.dart` into a dedicated widget file, `chat_messages_list.dart`, thereby reducing `chat_screen.dart` size and improving maintainability.

---

## 1. Create `chat_messages_list.dart`

1.1. **Location**: `lib/src/features/messages/presentation/chat_messages_list.dart`

1.2. **Widget**: `ChatMessagesList` implemented as a `ConsumerWidget`.

1.3. **Constructor parameters**
- `AsyncValue<List<MessageModel>> messagesValue`
- `ConversationModel conversation`
- `String currentUserId`
- `ScrollController scrollController`

1.4. **Internal helpers** (moved from `chat_screen.dart`)
- `_buildMessagesList`
- `_buildEmptyState`
- `_buildErrorState`
- `_buildTimestampDivider`
- `_buildMessageBubble`
- `_buildMessageContent`
- `_buildMediaMessage`
- `_shouldShowTimestamp`
- `_formatTimestampDivider`

1.5. **Dependencies / imports**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/conversation_model.dart';
import '../data/message_model.dart';
import '../data/messages_notifier.dart';
import 'media_viewer_screen.dart';
```

All helper logic remains unchanged except replacing `widget.conversation` with `conversation` and removing references to the enclosing `State`.

---

## 2. Update `chat_screen.dart`

2.1 **Add import**
```dart
import 'chat_messages_list.dart';
```

2.2 **Replace Expanded message list**
```dart
Expanded(
  child: ChatMessagesList(
    messagesValue: messagesValue,
    conversation: widget.conversation,
    currentUserId: currentUser?.uid ?? '',
    scrollController: _scrollController,
  ),
),
```

2.3 **Delete extracted helpers**
Remove the following methods from `_ChatScreenState`:
- `_buildMessagesList`
- `_buildEmptyState`
- `_buildErrorState`
- `_buildTimestampDivider`
- `_buildMessageBubble`
- `_buildMessageContent`
- `_buildMediaMessage`
- `_shouldShowTimestamp`
- `_formatTimestampDivider`

> Ensure no dangling references remain.

---

## 3. Verify scrolling logic
`_scrollToBottom` in `chat_screen.dart` continues to use the shared `ScrollController` passed to `ChatMessagesList`.

---

## 4. Lint & compile
1. Run `flutter analyze` to ensure no lints.
2. Run `flutter test` or build to confirm compilation.

---

## 5. Commit message suggestion
```
refactor(messages): extract ChatMessagesList widget

Moved all message-list rendering logic into its own widget file to keep
chat_screen.dart under 400 lines and improve readability.
```