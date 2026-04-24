import 'package:drift/drift.dart';

// The generated file is produced by running:
//   flutter pub run build_runner build --delete-conflicting-outputs
//
// Because this environment does not have the Flutter SDK, the .g.dart file
// must be generated on a machine with Flutter installed.
part 'app_database.g.dart';

/// A local decision recorded during a decluttering session.
class LocalDecisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionKey => text()();
  TextColumn get groupId => text()();
  TextColumn get groupLabel => text()();
  IntColumn get groupTotal => integer()();
  TextColumn get category => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get note => text().nullable()();
}

/// A remote decision that failed to sync and is queued for retry.
class PendingRemoteDecisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionKey => text()();
  TextColumn get groupId => text()();
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
}

/// Drift database for persisting session state across app restarts.
@DriftDatabase(tables: [LocalDecisions, PendingRemoteDecisions])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  /// Returns all local decisions for a given session, newest first.
  Future<List<LocalDecision>> decisionsForSession(String sessionKey) async {
    return (select(localDecisions)
          ..where((d) => d.sessionKey.equals(sessionKey))
          ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
        .get();
  }

  /// Inserts a new local decision.
  Future<int> insertDecision(LocalDecisionsCompanion decision) async {
    return into(localDecisions).insert(decision);
  }

  /// Deletes all decisions for a session.
  Future<int> clearSessionDecisions(String sessionKey) async {
    return (delete(localDecisions)
          ..where((d) => d.sessionKey.equals(sessionKey)))
        .go();
  }

  /// Deletes decisions older than [cutoff].
  Future<int> deleteDecisionsOlderThan(DateTime cutoff) async {
    return (delete(localDecisions)
          ..where((d) => d.createdAt.isSmallerThanValue(cutoff)))
        .go();
  }

  /// Returns pending remote decisions for a session.
  Future<List<PendingRemoteDecision>> pendingForSession(
    String sessionKey,
  ) async {
    return (select(pendingRemoteDecisions)
          ..where((p) => p.sessionKey.equals(sessionKey)))
        .get();
  }

  /// Inserts a pending remote decision.
  Future<int> insertPending(PendingRemoteDecisionsCompanion pending) async {
    return into(pendingRemoteDecisions).insert(pending);
  }

  /// Deletes a pending remote decision by id.
  Future<int> deletePending(int id) async {
    return (delete(pendingRemoteDecisions)
          ..where((p) => p.id.equals(id)))
        .go();
  }

  /// Deletes all pending remote decisions for a session.
  Future<int> clearSessionPending(String sessionKey) async {
    return (delete(pendingRemoteDecisions)
          ..where((p) => p.sessionKey.equals(sessionKey)))
        .go();
  }
}
