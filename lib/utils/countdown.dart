/// Formate un nombre de jours restants en texte lisible ("dans 12 jours").
String formatCountdown(int daysUntil) {
  if (daysUntil == 0) return "Aujourd'hui";
  if (daysUntil == 1) return 'Demain';
  return 'Dans $daysUntil jours';
}
