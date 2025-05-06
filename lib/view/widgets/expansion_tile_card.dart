import 'package:flutter/material.dart';

class ExpansionTileCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final VoidCallback? onExpand;
  final bool initiallyExpanded;

  const ExpansionTileCard({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.onExpand,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        onExpansionChanged: (expanded) {
          if (expanded && onExpand != null) {
            onExpand!();
          }
        },
        children: [content],
      ),
    );
  }
}
