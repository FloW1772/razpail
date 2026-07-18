import 'package:hive/hive.dart';

import 'recurrence.dart';

part 'reminder.g.dart';

/// Représente un rappel d'anniversaire stocké localement.
@HiveType(typeId: 0)
class Reminder extends HiveObject {
  Reminder({
    required this.id,
    required this.name,
    required this.message,
    required this.date,
    required this.notificationHour,
    required this.notificationMinute,
    required this.recurrence,
  });

  /// Identifiant unique, utilisé aussi comme id de notification planifiée.
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String message;

  /// Date de l'événement. Pour les rappels annuels, seuls le jour et le mois
  /// comptent : l'année sert uniquement de référence initiale.
  @HiveField(3)
  DateTime date;

  @HiveField(4)
  int notificationHour;

  @HiveField(5)
  int notificationMinute;

  @HiveField(6)
  Recurrence recurrence;

  /// Prochaine échéance à partir de [from] (aujourd'hui par défaut),
  /// en tenant compte de la récurrence annuelle.
  DateTime nextOccurrence({DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var occurrence = DateTime(
      date.year,
      date.month,
      date.day,
      notificationHour,
      notificationMinute,
    );

    if (recurrence == Recurrence.once) {
      return occurrence;
    }

    occurrence = DateTime(
      now.year,
      date.month,
      date.day,
      notificationHour,
      notificationMinute,
    );

    final occurrenceDay = DateTime(now.year, date.month, date.day);
    if (occurrenceDay.isBefore(today)) {
      occurrence = DateTime(
        now.year + 1,
        date.month,
        date.day,
        notificationHour,
        notificationMinute,
      );
    }

    return occurrence;
  }

  /// Nombre de jours entiers avant la prochaine échéance (0 = aujourd'hui).
  int daysUntilNext({DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = nextOccurrence(from: now);
    final nextDay = DateTime(next.year, next.month, next.day);
    return nextDay.difference(today).inDays;
  }

  /// Rappel passé et non répétable : ne sera plus jamais notifié.
  bool get isPastAndOver {
    if (recurrence == Recurrence.yearly) return false;
    return nextOccurrence().isBefore(DateTime.now());
  }
}
