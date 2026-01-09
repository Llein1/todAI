import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Stats Row Widget
/// Displays quick statistics in a row of mini cards
class StatsRow extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final double completionRate;

  const StatsRow({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingMedium,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.list_alt,
              value: '$totalTasks',
              label: 'Total',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle,
              value: '$completedTasks',
              label: 'Done',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: _StatCard(
              icon: Icons.pending_actions,
              value: '$pendingTasks',
              label: 'Pending',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Expanded(
            child: _StatCard(
              icon: Icons.pie_chart,
              value: '${completionRate.toStringAsFixed(0)}%',
              label: 'Rate',
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: UIConstants.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: UIConstants.iconMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
