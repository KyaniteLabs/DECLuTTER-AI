import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';

import '../../../core/data/app_database.dart';
import '../../../core/data/database_provider.dart';
import '../domain/session_decision.dart';

/// Repository for persisting session decisions locally via Drift.
///
/// Falls back to no-op if the database is unavailable (e.g. before
/// `build_runner` has generated the `.g.dart` file or on first run).
class SessionDecisionRepository {
  SessionDecisionRepository({AppDatabase? database})
      : _db = database ?? DatabaseProvider.instance;

  final AppDatabase _db;

  /// Loads all decisions for a session, newest first.
  Future<List<SessionDecision>> loadDecisions(String sessionKey) async {
    try {
      final rows = await _db.decisionsForSession(sessionKey);
      return rows.map(_mapRowToDecision).toList();
    } catch (e) {
      debugPrint('SessionDecisionRepository: load failed: $e');
      return const [];
    }
  }

  /// Saves a single decision.
  Future<void> saveDecision(String sessionKey, SessionDecision decision) async {
    try {
      await _db.insertDecision(
        LocalDecisionsCompanion.insert(
          sessionKey: sessionKey,
          groupId: decision.groupId,
          groupLabel: decision.groupLabel,
          groupTotal: decision.groupTotal,
          category: decision.category.name,
          createdAt: decision.createdAt,
          note: decision.note != null && decision.note!.isNotEmpty
              ? Value(decision.note)
              : const Value.absent(),
        ),
      );
    } catch (e) {
      debugPrint('SessionDecisionRepository: save failed: $e');
    }
  }

  /// Clears all decisions for a session.
  Future<void> clearSession(String sessionKey) async {
    try {
      await _db.clearSessionDecisions(sessionKey);
      await _db.clearSessionPending(sessionKey);
    } catch (e) {
      debugPrint('SessionDecisionRepository: clear failed: $e');
    }
  }

  /// Deletes stale decisions older than [age].
  Future<void> deleteOlderThan(Duration age) async {
    try {
      final cutoff = DateTime.now().subtract(age);
      await _db.deleteDecisionsOlderThan(cutoff);
    } catch (e) {
      debugPrint('SessionDecisionRepository: cleanup failed: $e');
    }
  }

  SessionDecision _mapRowToDecision(LocalDecision row) {
    return SessionDecision(
      groupId: row.groupId,
      groupLabel: row.groupLabel,
      groupTotal: row.groupTotal,
      category: DecisionCategory.values.byName(row.category),
      createdAt: row.createdAt,
      note: row.note,
    );
  }
}
