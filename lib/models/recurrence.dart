import 'package:hive/hive.dart';

part 'recurrence.g.dart';

/// Fréquence de répétition d'un rappel.
@HiveType(typeId: 1)
enum Recurrence {
  @HiveField(0)
  once,

  @HiveField(1)
  yearly,
}

extension RecurrenceLabel on Recurrence {
  String get label {
    switch (this) {
      case Recurrence.once:
        return 'Une seule fois';
      case Recurrence.yearly:
        return 'Chaque année';
    }
  }

  String get badge {
    switch (this) {
      case Recurrence.once:
        return 'Unique';
      case Recurrence.yearly:
        return 'Annuel';
    }
  }
}
