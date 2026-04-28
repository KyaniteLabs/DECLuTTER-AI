import 'package:flutter/material.dart';

import '../../../data/repositories/session_repository.dart';
import '../../grouping/domain/detection_group.dart';
import '../../grouping/domain/grouped_detection_result.dart';
import '../../session/domain/session_decision.dart';
import '../../summary/presentation/session_summary_screen.dart';
import '../../valuate/models/valuation.dart';
import '../../settings/presentation/settings_screen.dart';

/// Lists all persisted declutter sessions with quick stats.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SessionRepository _repository = SessionRepository();
  List<PersistedSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await _repository.listSessions();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  Future<void> _delete(String id) async {
    await _repository.deleteSession(id);
    await _load();
  }

  void _openSessionSummary(BuildContext context, PersistedSession session) {
    final groupedResult = GroupedDetectionResult(
      groups: session.groups.map((g) => DetectionGroup(
        id: g.id,
        rawLabel: g.label,
        displayLabel: g.label,
        detections: const [],
      )).toList(),
      totalDetections: session.totalItems,
      originalSize: Size.zero,
      isMocked: false,
    );

    final decisions = <String, SessionDecision>{};
    for (final d in session.decisions) {
      final category = DecisionCategory.values.firstWhere(
        (c) => c.name == d.category,
        orElse: () => DecisionCategory.maybe,
      );
      decisions[d.groupId] = SessionDecision(
        groupId: d.groupId,
        groupLabel: session.groups.firstWhere(
          (g) => g.id == d.groupId,
          orElse: () => PersistedGroup(
            id: d.groupId,
            sessionId: session.id,
            label: 'Group',
            itemCount: 1,
            averageConfidence: 0,
            createdAt: session.createdAt,
          ),
        ).label,
        groupTotal: 1,
        category: category,
        createdAt: d.createdAt,
        note: d.note,
      );
    }

    final valuations = <String, Valuation?>{};
    for (final v in session.valuations) {
      valuations[v.groupId] = Valuation(
        low: v.lowUsd,
        mid: v.midUsd,
        high: v.highUsd,
        confidence: v.confidence,
      );
    }

    final duration = session.completedAt != null
        ? session.completedAt!.difference(session.createdAt)
        : Duration.zero;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionSummaryScreen(
          groupedResult: groupedResult,
          decisions: decisions,
          valuations: valuations,
          sessionDuration: duration,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _sessions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sessions yet',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Complete a 10-min sprint and your history will appear here. Sessions are stored locally on your device.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return _SessionCard(
                        session: session,
                        onDelete: () => _delete(session.id),
                        onTap: () => _openSessionSummary(context, session),
                      );
                    },
                  ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onDelete,
    this.onTap,
  });

  final PersistedSession session;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr =
        '${session.createdAt.year}-${session.createdAt.month.toString().padLeft(2, '0')}-${session.createdAt.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${session.createdAt.hour.toString().padLeft(2, '0')}:${session.createdAt.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$dateStr at $timeStr',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  tooltip: 'Delete session',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _StatChip(
                  icon: Icons.layers_outlined,
                  label: '${session.totalItems} items',
                ),
                _StatChip(
                  icon: Icons.check_circle_outline,
                  label: '${session.decidedCount} decided',
                ),
                if (session.moneyOnTableLowUsd != null &&
                    session.moneyOnTableHighUsd != null)
                  _StatChip(
                    icon: Icons.attach_money,
                    label:
                        '\$${session.moneyOnTableLowUsd!.toStringAsFixed(0)}–${session.moneyOnTableHighUsd!.toStringAsFixed(0)}',
                  ),
              ],
            ),
            if (session.groups.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: session.groups.map((g) {
                  return Chip(
                    label: Text('${g.label} · ${g.itemCount}'),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    ),
  );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
