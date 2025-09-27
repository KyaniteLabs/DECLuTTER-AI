import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/session_decision.dart';
import 'widgets/focus_timer.dart';
import 'widgets/quick_start_card.dart';

class SessionTimerScreen extends StatefulWidget {
  const SessionTimerScreen({super.key, this.capturedImagePath, this.capturedAt});

  final String? capturedImagePath;
  final DateTime? capturedAt;

  @override
  State<SessionTimerScreen> createState() => _SessionTimerScreenState();
}

class _SessionTimerScreenState extends State<SessionTimerScreen> {
  final List<SessionDecision> _decisions = [];

  Future<void> _handleDecision(DecisionCategory category) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _DecisionNoteSheet(category: category),
    );

    if (!mounted || note == null) {
      return;
    }

    setState(() {
      _decisions.insert(
        0,
        SessionDecision(
          category: category,
          createdAt: DateTime.now(),
          note: note.isEmpty ? null : note,
        ),
      );
    });
  }

  void _handleTimerCompleted() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => const _TimerCompleteSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('10-Min Declutter Sprint'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.capturedImagePath != null)
              _CapturedPhotoPreview(
                imagePath: widget.capturedImagePath!,
                capturedAt: widget.capturedAt,
              ),
            const QuickStartCard(),
            const SizedBox(height: 24),
            FocusTimer(onCompleted: _handleTimerCompleted),
            const SizedBox(height: 24),
            SessionDecisionComposer(onCategorySelected: _handleDecision),
            const SizedBox(height: 16),
            SessionDecisionHistory(decisions: _decisions),
          ],
        ),
      ),
    );
  }
}

class _CapturedPhotoPreview extends StatelessWidget {
  const _CapturedPhotoPreview({required this.imagePath, this.capturedAt});

  final String imagePath;
  final DateTime? capturedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!kIsWeb)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                height: 180,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Preview not available on web build, but your capture is saved.'),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Captured zone snapshot',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (capturedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Taken ${TimeOfDay.fromDateTime(capturedAt!).format(context)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'Next up: the model will find clusters so you can move through Keep, Donate/Sell, Trash, Relocate, or Maybe decisions.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SessionDecisionComposer extends StatelessWidget {
  const SessionDecisionComposer({super.key, required this.onCategorySelected});

  final ValueChanged<DecisionCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log your decisions',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Tap a bucket, jot the action you took, and keep the momentum going.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: DecisionCategory.values
                  .map(
                    (category) => FilledButton.tonalIcon(
                      onPressed: () => onCategorySelected(category),
                      icon: Icon(category.icon),
                      label: Text(category.label),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionDecisionHistory extends StatelessWidget {
  const SessionDecisionHistory({super.key, required this.decisions});

  final List<SessionDecision> decisions;

  @override
  Widget build(BuildContext context) {
    if (decisions.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Decisions appear here',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Each logged action drops into this running list so your summary writes itself.'),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Session log',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...decisions.map(
          (decision) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: decision.category.containerColor(theme.colorScheme),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            decision.category.icon,
                            color: decision.category.foregroundColor(theme.colorScheme),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            decision.category.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: decision.category.foregroundColor(theme.colorScheme),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        TimeOfDay.fromDateTime(decision.createdAt).format(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: decision.category.foregroundColor(theme.colorScheme),
                        ),
                      ),
                    ],
                  ),
                  if (decision.note != null && decision.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      decision.note!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: decision.category.foregroundColor(theme.colorScheme),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DecisionNoteSheet extends StatefulWidget {
  const _DecisionNoteSheet({required this.category});

  final DecisionCategory category;

  @override
  State<_DecisionNoteSheet> createState() => _DecisionNoteSheetState();
}

class _DecisionNoteSheetState extends State<_DecisionNoteSheet> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.category.icon),
              const SizedBox(width: 8),
              Text(
                widget.category.label,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'What action did you take?',
              hintText: 'e.g. Boxed kids books for library drop-off',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => Navigator.of(context).pop(_controller.text.trim()),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
              child: const Text('Save decision'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerCompleteSheet extends StatelessWidget {
  const _TimerCompleteSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time! Celebrate the wins',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text('• Log your decisions for each highlighted group.'),
          const SizedBox(height: 8),
          const Text('• If something feels sticky, tap Maybe and move on.'),
          const SizedBox(height: 8),
          const Text('• Finish strong with the summary screen when you are ready.'),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to sorting'),
            ),
          ),
        ],
      ),
    );
  }
}
