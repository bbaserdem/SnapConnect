/// TagService - reads tags from assets/tags.yaml and exposes them via Riverpod providers
///
/// YAML structure:
/// - tag: tattoos
///   category: tattoos
///   priority: 1
/// - tag: blackwork
///   category: tattoos
///   priority: 2
///
/// Exposed providers:
/// 1. tagEntriesProvider -> FutureProvider<List<TagEntry>>
///    Loads the full list of tag entries.
/// 2. tagsProvider -> FutureProvider<List<String>>
///    Convenience provider returning tag names only (all entries).
/// 3. curatedTagsProvider -> FutureProvider<List<String>>
///    Returns tags whose priority == 1 (for the profile setup screen).
///
/// The first call caches the parsed YAML for the lifetime of the ProviderContainer.

import 'dart:collection';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaml/yaml.dart';

/// Plain model representing a tag entry
class TagEntry {
  final String tag;
  final String category;
  final int priority;

  const TagEntry({required this.tag, required this.category, required this.priority});

  factory TagEntry.fromMap(Map<dynamic, dynamic> map) => TagEntry(
        tag: (map['tag'] as String).trim(),
        category: (map['category'] as String).trim(),
        priority: map['priority'] as int,
      );
}

Future<List<TagEntry>> _loadTagEntries() async {
  final raw = await rootBundle.loadString('assets/tags.yaml');
  final parsed = loadYaml(raw);
  if (parsed is! YamlList) throw Exception('Expected YAML list');

  final seen = LinkedHashSet<String>();
  final entries = <TagEntry>[];
  for (final node in parsed) {
    if (node is YamlMap) {
      final entry = TagEntry.fromMap(node);
      // Deduplicate by tag name (first occurrence wins)
      if (seen.add(entry.tag)) entries.add(entry);
    }
  }
  return entries;
}

/// Provider for all TagEntry objects
final tagEntriesProvider = FutureProvider<List<TagEntry>>((ref) async {
  return _loadTagEntries();
});

/// Provider exposing just the tag names (all priorities)
final tagsProvider = FutureProvider<List<String>>((ref) async {
  final entries = await ref.watch(tagEntriesProvider.future);
  return entries.map((e) => e.tag).toList(growable: false);
});

/// Provider exposing curated tag names (priority == 1)
final curatedTagsProvider = FutureProvider<List<String>>((ref) async {
  final entries = await ref.watch(tagEntriesProvider.future);
  return entries.where((e) => e.priority == 1).map((e) => e.tag).toList(growable: false);
}); 