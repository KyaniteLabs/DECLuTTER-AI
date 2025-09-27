import 'package:flutter/material.dart';

class QuickStartCard extends StatelessWidget {
  const QuickStartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sorting this zone just got easier',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '1. Zoom in on each highlighted group.\n2. Decide: Keep, Donate/Sell, Trash, Relocate, or Maybe.\n3. Move the item right away or log it so it appears in the summary.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _TipChip(label: 'Stay curious, not perfect.'),
                _TipChip(label: 'Analysis stays on-device by default.'),
                _TipChip(label: 'Need a breather? Pause or tap Maybe.'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.lightbulb_outline),
    );
  }
}
