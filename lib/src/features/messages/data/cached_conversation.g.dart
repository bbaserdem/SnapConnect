// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_conversation.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCachedConversationCollection on Isar {
  IsarCollection<CachedConversation> get cachedConversations =>
      this.collection();
}

const CachedConversationSchema = CollectionSchema(
  name: r'CachedConversation',
  id: 3264234806672372389,
  properties: {
    r'conversationId': PropertySchema(
      id: 0,
      name: r'conversationId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'groupAvatarUrl': PropertySchema(
      id: 2,
      name: r'groupAvatarUrl',
      type: IsarType.string,
    ),
    r'groupName': PropertySchema(
      id: 3,
      name: r'groupName',
      type: IsarType.string,
    ),
    r'isGroup': PropertySchema(
      id: 4,
      name: r'isGroup',
      type: IsarType.bool,
    ),
    r'lastMessageContent': PropertySchema(
      id: 5,
      name: r'lastMessageContent',
      type: IsarType.string,
    ),
    r'lastMessageId': PropertySchema(
      id: 6,
      name: r'lastMessageId',
      type: IsarType.string,
    ),
    r'lastMessageSenderId': PropertySchema(
      id: 7,
      name: r'lastMessageSenderId',
      type: IsarType.string,
    ),
    r'lastMessageTimestamp': PropertySchema(
      id: 8,
      name: r'lastMessageTimestamp',
      type: IsarType.dateTime,
    ),
    r'lastViewedTimestampsJson': PropertySchema(
      id: 9,
      name: r'lastViewedTimestampsJson',
      type: IsarType.string,
    ),
    r'participantIds': PropertySchema(
      id: 10,
      name: r'participantIds',
      type: IsarType.stringList,
    ),
    r'participantUsernamesJson': PropertySchema(
      id: 11,
      name: r'participantUsernamesJson',
      type: IsarType.string,
    ),
    r'unreadCountsJson': PropertySchema(
      id: 12,
      name: r'unreadCountsJson',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 13,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _cachedConversationEstimateSize,
  serialize: _cachedConversationSerialize,
  deserialize: _cachedConversationDeserialize,
  deserializeProp: _cachedConversationDeserializeProp,
  idName: r'id',
  indexes: {
    r'conversationId': IndexSchema(
      id: 2945908346256754300,
      name: r'conversationId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'conversationId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'lastMessageTimestamp': IndexSchema(
      id: -4166944236939691770,
      name: r'lastMessageTimestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastMessageTimestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cachedConversationGetId,
  getLinks: _cachedConversationGetLinks,
  attach: _cachedConversationAttach,
  version: '3.1.8',
);

int _cachedConversationEstimateSize(
  CachedConversation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.conversationId.length * 3;
  {
    final value = object.groupAvatarUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.groupName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMessageContent;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMessageId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastMessageSenderId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.lastViewedTimestampsJson.length * 3;
  bytesCount += 3 + object.participantIds.length * 3;
  {
    for (var i = 0; i < object.participantIds.length; i++) {
      final value = object.participantIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.participantUsernamesJson.length * 3;
  bytesCount += 3 + object.unreadCountsJson.length * 3;
  return bytesCount;
}

void _cachedConversationSerialize(
  CachedConversation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.conversationId);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.groupAvatarUrl);
  writer.writeString(offsets[3], object.groupName);
  writer.writeBool(offsets[4], object.isGroup);
  writer.writeString(offsets[5], object.lastMessageContent);
  writer.writeString(offsets[6], object.lastMessageId);
  writer.writeString(offsets[7], object.lastMessageSenderId);
  writer.writeDateTime(offsets[8], object.lastMessageTimestamp);
  writer.writeString(offsets[9], object.lastViewedTimestampsJson);
  writer.writeStringList(offsets[10], object.participantIds);
  writer.writeString(offsets[11], object.participantUsernamesJson);
  writer.writeString(offsets[12], object.unreadCountsJson);
  writer.writeDateTime(offsets[13], object.updatedAt);
}

CachedConversation _cachedConversationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CachedConversation();
  object.conversationId = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.groupAvatarUrl = reader.readStringOrNull(offsets[2]);
  object.groupName = reader.readStringOrNull(offsets[3]);
  object.id = id;
  object.isGroup = reader.readBool(offsets[4]);
  object.lastMessageContent = reader.readStringOrNull(offsets[5]);
  object.lastMessageId = reader.readStringOrNull(offsets[6]);
  object.lastMessageSenderId = reader.readStringOrNull(offsets[7]);
  object.lastMessageTimestamp = reader.readDateTimeOrNull(offsets[8]);
  object.lastViewedTimestampsJson = reader.readString(offsets[9]);
  object.participantIds = reader.readStringList(offsets[10]) ?? [];
  object.participantUsernamesJson = reader.readString(offsets[11]);
  object.unreadCountsJson = reader.readString(offsets[12]);
  object.updatedAt = reader.readDateTime(offsets[13]);
  return object;
}

P _cachedConversationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cachedConversationGetId(CachedConversation object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cachedConversationGetLinks(
    CachedConversation object) {
  return [];
}

void _cachedConversationAttach(
    IsarCollection<dynamic> col, Id id, CachedConversation object) {
  object.id = id;
}

extension CachedConversationByIndex on IsarCollection<CachedConversation> {
  Future<CachedConversation?> getByConversationId(String conversationId) {
    return getByIndex(r'conversationId', [conversationId]);
  }

  CachedConversation? getByConversationIdSync(String conversationId) {
    return getByIndexSync(r'conversationId', [conversationId]);
  }

  Future<bool> deleteByConversationId(String conversationId) {
    return deleteByIndex(r'conversationId', [conversationId]);
  }

  bool deleteByConversationIdSync(String conversationId) {
    return deleteByIndexSync(r'conversationId', [conversationId]);
  }

  Future<List<CachedConversation?>> getAllByConversationId(
      List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'conversationId', values);
  }

  List<CachedConversation?> getAllByConversationIdSync(
      List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'conversationId', values);
  }

  Future<int> deleteAllByConversationId(List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'conversationId', values);
  }

  int deleteAllByConversationIdSync(List<String> conversationIdValues) {
    final values = conversationIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'conversationId', values);
  }

  Future<Id> putByConversationId(CachedConversation object) {
    return putByIndex(r'conversationId', object);
  }

  Id putByConversationIdSync(CachedConversation object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'conversationId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByConversationId(List<CachedConversation> objects) {
    return putAllByIndex(r'conversationId', objects);
  }

  List<Id> putAllByConversationIdSync(List<CachedConversation> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'conversationId', objects, saveLinks: saveLinks);
  }
}

extension CachedConversationQueryWhereSort
    on QueryBuilder<CachedConversation, CachedConversation, QWhere> {
  QueryBuilder<CachedConversation, CachedConversation, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhere>
      anyLastMessageTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastMessageTimestamp'),
      );
    });
  }
}

extension CachedConversationQueryWhere
    on QueryBuilder<CachedConversation, CachedConversation, QWhereClause> {
  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      conversationIdEqualTo(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'conversationId',
        value: [conversationId],
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      conversationIdNotEqualTo(String conversationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [conversationId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'conversationId',
              lower: [],
              upper: [conversationId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      lastMessageTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastMessageTimestamp',
        value: [null],
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      lastMessageTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastMessageTimestamp',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      lastMessageTimestampEqualTo(DateTime? lastMessageTimestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastMessageTimestamp',
        value: [lastMessageTimestamp],
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      lastMessageTimestampNotEqualTo(DateTime? lastMessageTimestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastMessageTimestamp',
              lower: [],
              upper: [lastMessageTimestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastMessageTimestamp',
              lower: [lastMessageTimestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastMessageTimestamp',
              lower: [lastMessageTimestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastMessageTimestamp',
              lower: [],
              upper: [lastMessageTimestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      lastMessageTimestampGreaterThan(
    DateTime? lastMessageTimestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastMessageTimestamp',
        lower: [lastMessageTimestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      lastMessageTimestampLessThan(
    DateTime? lastMessageTimestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastMessageTimestamp',
        lower: [],
        upper: [lastMessageTimestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterWhereClause>
      lastMessageTimestampBetween(
    DateTime? lowerLastMessageTimestamp,
    DateTime? upperLastMessageTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastMessageTimestamp',
        lower: [lowerLastMessageTimestamp],
        includeLower: includeLower,
        upper: [upperLastMessageTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CachedConversationQueryFilter
    on QueryBuilder<CachedConversation, CachedConversation, QFilterCondition> {
  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'conversationId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'conversationId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'conversationId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      conversationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'conversationId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'groupAvatarUrl',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'groupAvatarUrl',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groupAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groupAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groupAvatarUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'groupAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'groupAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'groupAvatarUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'groupAvatarUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupAvatarUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupAvatarUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'groupAvatarUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'groupName',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'groupName',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groupName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groupName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groupName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'groupName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'groupName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'groupName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'groupName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupName',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      groupNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'groupName',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      isGroupEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isGroup',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessageContent',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessageContent',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessageContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessageContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessageContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessageContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageContent',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessageContent',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessageId',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessageId',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessageId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessageId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessageId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessageSenderId',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessageSenderId',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageSenderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageSenderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageSenderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageSenderId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastMessageSenderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastMessageSenderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastMessageSenderId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastMessageSenderId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageSenderId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageSenderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastMessageSenderId',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessageTimestamp',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessageTimestamp',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageTimestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageTimestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageTimestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastMessageTimestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastViewedTimestampsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastViewedTimestampsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastViewedTimestampsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastViewedTimestampsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastViewedTimestampsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastViewedTimestampsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastViewedTimestampsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastViewedTimestampsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastViewedTimestampsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      lastViewedTimestampsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastViewedTimestampsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'participantIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'participantIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'participantIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'participantIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'participantIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'participantIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'participantIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantIds',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'participantIds',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'participantIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantUsernamesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'participantUsernamesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'participantUsernamesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'participantUsernamesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'participantUsernamesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'participantUsernamesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'participantUsernamesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'participantUsernamesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'participantUsernamesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      participantUsernamesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'participantUsernamesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unreadCountsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unreadCountsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unreadCountsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unreadCountsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unreadCountsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unreadCountsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unreadCountsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unreadCountsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unreadCountsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      unreadCountsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unreadCountsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CachedConversationQueryObject
    on QueryBuilder<CachedConversation, CachedConversation, QFilterCondition> {}

extension CachedConversationQueryLinks
    on QueryBuilder<CachedConversation, CachedConversation, QFilterCondition> {}

extension CachedConversationQuerySortBy
    on QueryBuilder<CachedConversation, CachedConversation, QSortBy> {
  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByGroupAvatarUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupAvatarUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByGroupAvatarUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupAvatarUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByGroupName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupName', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByGroupNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupName', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByIsGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroup', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByIsGroupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroup', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastMessageContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageContent', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastMessageContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageContent', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastMessageSenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageSenderId', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastMessageSenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageSenderId', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastMessageTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageTimestamp', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastMessageTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageTimestamp', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastViewedTimestampsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedTimestampsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByLastViewedTimestampsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedTimestampsJson', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByParticipantUsernamesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantUsernamesJson', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByParticipantUsernamesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantUsernamesJson', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByUnreadCountsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCountsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByUnreadCountsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCountsJson', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CachedConversationQuerySortThenBy
    on QueryBuilder<CachedConversation, CachedConversation, QSortThenBy> {
  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByConversationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByConversationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'conversationId', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByGroupAvatarUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupAvatarUrl', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByGroupAvatarUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupAvatarUrl', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByGroupName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupName', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByGroupNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupName', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByIsGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroup', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByIsGroupDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroup', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastMessageContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageContent', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastMessageContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageContent', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastMessageSenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageSenderId', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastMessageSenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageSenderId', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastMessageTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageTimestamp', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastMessageTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageTimestamp', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastViewedTimestampsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedTimestampsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByLastViewedTimestampsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastViewedTimestampsJson', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByParticipantUsernamesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantUsernamesJson', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByParticipantUsernamesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'participantUsernamesJson', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByUnreadCountsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCountsJson', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByUnreadCountsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCountsJson', Sort.desc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension CachedConversationQueryWhereDistinct
    on QueryBuilder<CachedConversation, CachedConversation, QDistinct> {
  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByConversationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'conversationId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByGroupAvatarUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupAvatarUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByGroupName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByIsGroup() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGroup');
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByLastMessageContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageContent',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByLastMessageId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByLastMessageSenderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageSenderId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByLastMessageTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageTimestamp');
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByLastViewedTimestampsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastViewedTimestampsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByParticipantIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantIds');
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByParticipantUsernamesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'participantUsernamesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByUnreadCountsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unreadCountsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CachedConversation, CachedConversation, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension CachedConversationQueryProperty
    on QueryBuilder<CachedConversation, CachedConversation, QQueryProperty> {
  QueryBuilder<CachedConversation, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CachedConversation, String, QQueryOperations>
      conversationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'conversationId');
    });
  }

  QueryBuilder<CachedConversation, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CachedConversation, String?, QQueryOperations>
      groupAvatarUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupAvatarUrl');
    });
  }

  QueryBuilder<CachedConversation, String?, QQueryOperations>
      groupNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupName');
    });
  }

  QueryBuilder<CachedConversation, bool, QQueryOperations> isGroupProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGroup');
    });
  }

  QueryBuilder<CachedConversation, String?, QQueryOperations>
      lastMessageContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageContent');
    });
  }

  QueryBuilder<CachedConversation, String?, QQueryOperations>
      lastMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageId');
    });
  }

  QueryBuilder<CachedConversation, String?, QQueryOperations>
      lastMessageSenderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageSenderId');
    });
  }

  QueryBuilder<CachedConversation, DateTime?, QQueryOperations>
      lastMessageTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageTimestamp');
    });
  }

  QueryBuilder<CachedConversation, String, QQueryOperations>
      lastViewedTimestampsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastViewedTimestampsJson');
    });
  }

  QueryBuilder<CachedConversation, List<String>, QQueryOperations>
      participantIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantIds');
    });
  }

  QueryBuilder<CachedConversation, String, QQueryOperations>
      participantUsernamesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'participantUsernamesJson');
    });
  }

  QueryBuilder<CachedConversation, String, QQueryOperations>
      unreadCountsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unreadCountsJson');
    });
  }

  QueryBuilder<CachedConversation, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
