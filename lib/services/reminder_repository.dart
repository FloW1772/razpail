import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/reminder.dart';
import '../models/recurrence.dart';

/// Accès unique aux rappels stockés localement (Hive), sans aucune
/// synchronisation réseau : toutes les données restent sur l'appareil.
class ReminderRepository extends ChangeNotifier {
  ReminderRepository._(this._box);

  static const String boxName = 'reminders';

  final Box<Reminder> _box;

  static Future<ReminderRepository> open() async {
    Hive.registerAdapter(RecurrenceAdapter());
    Hive.registerAdapter(ReminderAdapter());
    final box = await Hive.openBox<Reminder>(boxName);
    return ReminderRepository._(box);
  }

  /// Rappels triés par prochaine échéance (les plus proches en premier).
  List<Reminder> get sortedReminders {
    final reminders = _box.values.toList();
    reminders.sort((a, b) => a.nextOccurrence().compareTo(b.nextOccurrence()));
    return reminders;
  }

  Reminder? getById(String id) => _box.get(id);

  Future<void> save(Reminder reminder) async {
    await _box.put(reminder.id, reminder);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
