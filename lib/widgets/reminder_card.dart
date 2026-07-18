import 'package:flutter/material.dart';

import '../models/recurrence.dart';
import '../models/reminder.dart';
import '../utils/avatar_colors.dart';
import '../utils/countdown.dart';

/// Carte haut de gamme représentant un rappel dans la liste principale :
/// avatar coloré avec initiales, compte à rebours et badge de récurrence.
class ReminderCard extends StatelessWidget {
  const ReminderCard({super.key, required this.reminder, this.onTap});

  final Reminder reminder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final avatarColor = avatarColorFor(reminder.name);
    final isYearly = reminder.recurrence == Recurrence.yearly;
    final daysUntil = reminder.daysUntilNext();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: avatarColor.withValues(alpha: 0.18),
                child: Text(
                  initialsFor(reminder.name),
                  style: textTheme.titleLarge?.copyWith(
                    color: avatarColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCountdown(daysUntil),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _RecurrenceBadge(isYearly: isYearly),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecurrenceBadge extends StatelessWidget {
  const _RecurrenceBadge({required this.isYearly});

  final bool isYearly;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = isYearly ? scheme.secondary : scheme.tertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isYearly ? 'Annuel' : 'Unique',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
