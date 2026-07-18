import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/reminder_repository.dart';
import '../widgets/empty_state.dart';
import '../widgets/reminder_card.dart';
import 'form_screen.dart';

/// Écran principal : liste des rappels triés par prochaine échéance.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _delete(BuildContext context, Reminder reminder) async {
    final repository = context.read<ReminderRepository>();
    final messenger = ScaffoldMessenger.of(context);

    await NotificationService.instance.cancelForReminder(reminder.id);
    await repository.delete(reminder.id);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Text('Rappel pour ${reminder.name} supprimé'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () async {
            await repository.save(reminder);
            await NotificationService.instance.scheduleForReminder(reminder);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mémo Anniversaires'),
      ),
      body: Consumer<ReminderRepository>(
        builder: (context, repository, _) {
          final reminders = repository.sortedReminders;

          if (reminders.isEmpty) {
            return const EmptyState();
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: ListView.separated(
              key: ValueKey(reminders.length),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 250 + index * 40),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 16),
                        child: child,
                      ),
                    );
                  },
                  child: Dismissible(
                    key: ValueKey(reminder.id),
                    direction: DismissDirection.endToStart,
                    background: _buildDismissBackground(context),
                    onDismissed: (_) => _delete(context, reminder),
                    child: ReminderCard(
                      reminder: reminder,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FormScreen(reminder: reminder),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _AnimatedAddButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FormScreen()),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(Icons.delete_outline_rounded, color: scheme.onErrorContainer),
    );
  }
}

class _AnimatedAddButton extends StatefulWidget {
  const _AnimatedAddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<_AnimatedAddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..repeat(reverse: true, period: const Duration(seconds: 3));

  late final Animation<double> _scale =
      Tween(begin: 1.0, end: 1.06).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FloatingActionButton.extended(
        onPressed: widget.onPressed,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouveau rappel'),
      ),
    );
  }
}
