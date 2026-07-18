import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/recurrence.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/reminder_repository.dart';

const _uuid = Uuid();

/// Formulaire moderne de création ou modification d'un rappel.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, this.reminder});

  /// Si fourni, le formulaire modifie ce rappel existant.
  final Reminder? reminder;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _messageController;
  late DateTime _date;
  late TimeOfDay _time;
  late Recurrence _recurrence;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _nameController = TextEditingController(text: reminder?.name ?? '');
    _messageController = TextEditingController(text: reminder?.message ?? '');
    _date = reminder?.date ?? DateTime.now();
    _time = TimeOfDay(
      hour: reminder?.notificationHour ?? 9,
      minute: reminder?.notificationMinute ?? 0,
    );
    _recurrence = reminder?.recurrence ?? Recurrence.yearly;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final reminder = Reminder(
      id: widget.reminder?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      message: _messageController.text.trim(),
      date: DateTime(_date.year, _date.month, _date.day),
      notificationHour: _time.hour,
      notificationMinute: _time.minute,
      recurrence: _recurrence,
    );

    final repository = context.read<ReminderRepository>();
    await repository.save(reminder);
    await NotificationService.instance.scheduleForReminder(reminder);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd('fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le rappel' : 'Nouveau rappel'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nom de la personne',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Merci d\'indiquer un nom'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message personnel',
                prefixIcon: Icon(Icons.favorite_outline_rounded),
                alignLabelWithHint: true,
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Merci d\'ajouter un message'
                  : null,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Date de l\'événement'),
            const SizedBox(height: 8),
            _PickerTile(
              icon: Icons.event_outlined,
              label: dateFormat.format(_date),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            _SectionLabel('Heure de notification'),
            const SizedBox(height: 8),
            _PickerTile(
              icon: Icons.schedule_outlined,
              label: _time.format(context),
              onTap: _pickTime,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Répétition'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: Recurrence.values.map((recurrence) {
                final selected = _recurrence == recurrence;
                return ChoiceChip(
                  label: Text(recurrence.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _recurrence = recurrence),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Enregistrer' : 'Créer le rappel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 14),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
