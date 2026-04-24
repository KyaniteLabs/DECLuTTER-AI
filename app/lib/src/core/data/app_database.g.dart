// GENERATED CODE - DO NOT MODIFY BY HAND
// Run the following command to regenerate:
//   flutter pub run build_runner build --delete-conflicting-outputs
//
// This stub file exists so the `part of` directive in app_database.dart
// resolves. It will be overwritten by Drift's code generator.

part of 'app_database.dart';

// ignore_for_file: type=lint

// Stubs to satisfy the analyzer until build_runner generates the real code.
// These are intentionally minimal and WILL be replaced by the generator.

class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(super.executor);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => [];

  @override
  int get schemaVersion => 1;

  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions();

  late final LocalDecisions localDecisions = LocalDecisions(this);
  late final PendingRemoteDecisions pendingRemoteDecisions =
      PendingRemoteDecisions(this);
}

class LocalDecisions extends Table with TableInfo<LocalDecisions, LocalDecision> {
  @override
  final GeneratedDatabase attachedDatabase;
  LocalDecisions(this.attachedDatabase);

  @override
  String get actualTableName => 'local_decisions';

  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', actualTableName, false, type: DriftSqlType.int, hasAutoIncrement: true, requiredDuringInsert: false);
  late final GeneratedColumn<String> sessionKey = GeneratedColumn<String>('session_key', actualTableName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>('group_id', actualTableName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> groupLabel = GeneratedColumn<String>('group_label', actualTableName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<int> groupTotal = GeneratedColumn<int>('group_total', actualTableName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  late final GeneratedColumn<String> category = GeneratedColumn<String>('category', actualTableName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', actualTableName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
  late final GeneratedColumn<String> note = GeneratedColumn<String>('note', actualTableName, true, type: DriftSqlType.string, requiredDuringInsert: false);

  @override
  List<GeneratedColumn<Object>> get $columns => [id, sessionKey, groupId, groupLabel, groupTotal, category, createdAt, note];

  @override
  LocalDecision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDecision(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${prefix}id'])!,
      sessionKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${prefix}session_key'])!,
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${prefix}group_id'])!,
      groupLabel: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${prefix}group_label'])!,
      groupTotal: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${prefix}group_total'])!,
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${prefix}category'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${prefix}created_at'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${prefix}note']),
    );
  }

  @override
  LocalDecisions createAlias(String alias) => LocalDecisions(attachedDatabase);

  @override
  bool get withoutRowId => false;

  @override
  bool get isStrict => false;

  @override
  List<String>? get customConstraints => null;

  @override
  Set<GeneratedColumn<Object>> get $primaryKey => {id};
}

class LocalDecision extends DataClass implements Insertable<LocalDecision> {
  final int id;
  final String sessionKey;
  final String groupId;
  final String groupLabel;
  final int groupTotal;
  final String category;
  final DateTime createdAt;
  final String? note;

  const LocalDecision({
    required this.id,
    required this.sessionKey,
    required this.groupId,
    required this.groupLabel,
    required this.groupTotal,
    required this.category,
    required this.createdAt,
    this.note,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return {
      'id': Variable<int>(id),
      'session_key': Variable<String>(sessionKey),
      'group_id': Variable<String>(groupId),
      'group_label': Variable<String>(groupLabel),
      'group_total': Variable<int>(groupTotal),
      'category': Variable<String>(category),
      'created_at': Variable<DateTime>(createdAt),
      if (note != null || nullToAbsent) 'note': Variable<String>(note),
    };
  }
}

class LocalDecisionsCompanion extends UpdateCompanion<LocalDecision> {
  final Value<int> id;
  final Value<String> sessionKey;
  final Value<String> groupId;
  final Value<String> groupLabel;
  final Value<int> groupTotal;
  final Value<String> category;
  final Value<DateTime> createdAt;
  final Value<String?> note;

  const LocalDecisionsCompanion({
    this.id = const Value.absent(),
    this.sessionKey = const Value.absent(),
    this.groupId = const Value.absent(),
    this.groupLabel = const Value.absent(),
    this.groupTotal = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.note = const Value.absent(),
  });

  LocalDecisionsCompanion.insert({
    this.id = const Value.absent(),
    required String this.sessionKey,
    required String this.groupId,
    required String this.groupLabel,
    required int this.groupTotal,
    required String this.category,
    required DateTime this.createdAt,
    this.note = const Value.absent(),
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object>>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (sessionKey.present) map['session_key'] = Variable<String>(sessionKey.value);
    if (groupId.present) map['group_id'] = Variable<String>(groupId.value);
    if (groupLabel.present) map['group_label'] = Variable<String>(groupLabel.value);
    if (groupTotal.present) map['group_total'] = Variable<int>(groupTotal.value);
    if (category.present) map['category'] = Variable<String>(category.value);
    if (createdAt.present) map['created_at'] = Variable<DateTime>(createdAt.value);
    if (note.present) map['note'] = Variable<String?>(note.value);
    return map;
  }
}

class PendingRemoteDecisions extends Table
    with TableInfo<PendingRemoteDecisions, PendingRemoteDecision> {
  @override
  final GeneratedDatabase attachedDatabase;
  PendingRemoteDecisions(this.attachedDatabase);

  @override
  String get actualTableName => 'pending_remote_decisions';

  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', actualTableName, false, type: DriftSqlType.int, hasAutoIncrement: true, requiredDuringInsert: false);
  late final GeneratedColumn<String> sessionKey = GeneratedColumn<String>('session_key', actualTableName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>('group_id', actualTableName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> category = GeneratedColumn<String>('category', actualTableName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  late final GeneratedColumn<String> note = GeneratedColumn<String>('note', actualTableName, true, type: DriftSqlType.string, requiredDuringInsert: false);

  @override
  List<GeneratedColumn<Object>> get $columns => [id, sessionKey, groupId, category, note];

  @override
  PendingRemoteDecision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingRemoteDecision(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${prefix}id'])!,
      sessionKey: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${prefix}session_key'])!,
      groupId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${prefix}group_id'])!,
      category: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${prefix}category'])!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${prefix}note']),
    );
  }

  @override
  PendingRemoteDecisions createAlias(String alias) => PendingRemoteDecisions(attachedDatabase);

  @override
  bool get withoutRowId => false;

  @override
  bool get isStrict => false;

  @override
  List<String>? get customConstraints => null;

  @override
  Set<GeneratedColumn<Object>> get $primaryKey => {id};
}

class PendingRemoteDecision extends DataClass
    implements Insertable<PendingRemoteDecision> {
  final int id;
  final String sessionKey;
  final String groupId;
  final String category;
  final String? note;

  const PendingRemoteDecision({
    required this.id,
    required this.sessionKey,
    required this.groupId,
    required this.category,
    this.note,
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return {
      'id': Variable<int>(id),
      'session_key': Variable<String>(sessionKey),
      'group_id': Variable<String>(groupId),
      'category': Variable<String>(category),
      if (note != null || nullToAbsent) 'note': Variable<String?>(note),
    };
  }
}

class PendingRemoteDecisionsCompanion
    extends UpdateCompanion<PendingRemoteDecision> {
  final Value<int> id;
  final Value<String> sessionKey;
  final Value<String> groupId;
  final Value<String> category;
  final Value<String?> note;

  const PendingRemoteDecisionsCompanion({
    this.id = const Value.absent(),
    this.sessionKey = const Value.absent(),
    this.groupId = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
  });

  PendingRemoteDecisionsCompanion.insert({
    this.id = const Value.absent(),
    required String this.sessionKey,
    required String this.groupId,
    required String this.category,
    this.note = const Value.absent(),
  });

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object>>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (sessionKey.present) map['session_key'] = Variable<String>(sessionKey.value);
    if (groupId.present) map['group_id'] = Variable<String>(groupId.value);
    if (category.present) map['category'] = Variable<String>(category.value);
    if (note.present) map['note'] = Variable<String?>(note.value);
    return map;
  }
}
