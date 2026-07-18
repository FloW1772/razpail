# Mémo Anniversaires

Application Android développée avec Flutter pour ne plus jamais oublier un
anniversaire, entièrement hors ligne : aucune connexion réseau, aucune
donnée envoyée où que ce soit.

## Fonctionnalités

- Création de rappels avec nom de la personne, message personnel, date et
  heure de notification (9h00 par défaut).
- Récurrence au choix : une seule fois, ou chaque année.
- Notification locale le jour J, affichant le nom et le message ; les
  rappels annuels se reprogramment automatiquement d'une année sur l'autre.
- Écran principal listant les rappels triés par prochaine échéance, avec
  compte à rebours ("dans 12 jours") et badge « Annuel » / « Unique ».
- Modification d'un rappel existant.
- Suppression par glissement, avec possibilité d'annuler l'action.
- Thème Material 3, clair et sombre, qui s'adapte automatiquement au
  système.

## Confidentialité et sécurité

- **Aucune permission INTERNET** n'est déclarée dans le manifeste de
  l'application (voir `android/app/src/main/AndroidManifest.xml`) : le
  build de release est physiquement incapable d'effectuer une requête
  réseau, d'appeler une API ou d'envoyer de la télémétrie.
- Toutes les données sont stockées localement sur l'appareil via
  [Hive](https://pub.dev/packages/hive), une base de données locale
  chiffrable et embarquée.
- Les notifications sont planifiées avec
  [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications),
  en alarmes exactes (`SCHEDULE_EXACT_ALARM`), et sont automatiquement
  reprogrammées après un redémarrage du téléphone.

> Note technique : les builds `debug` et `profile` déclarent la permission
> INTERNET afin que les outils de développement Flutter (hot reload,
> profiler) puissent communiquer avec l'appareil en local. Cette
> permission n'existe pas dans le manifeste principal et n'est donc jamais
> présente dans l'APK de release construit avec `flutter build apk
> --release`.

## Architecture du projet

```
lib/
├── main.dart                    Point d'entrée, initialisation et thème
├── models/
│   ├── reminder.dart             Modèle de rappel (Hive)
│   └── recurrence.dart           Enum de récurrence (une fois / annuel)
├── services/
│   ├── reminder_repository.dart  Accès au stockage local (Hive)
│   └── notification_service.dart Planification des notifications locales
├── screens/
│   ├── home_screen.dart          Liste des rappels
│   └── form_screen.dart          Création / modification d'un rappel
├── widgets/
│   ├── reminder_card.dart        Carte de rappel avec avatar et badge
│   └── empty_state.dart          Écran vide illustré
├── theme/
│   └── app_theme.dart            Thème Material 3 clair et sombre
└── utils/
    ├── avatar_colors.dart        Couleurs et initiales des avatars
    └── countdown.dart            Formatage du compte à rebours
```

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal
  stable, Dart >= 3.3).
- Android SDK avec un appareil ou émulateur Android 8.0 (API 26) minimum.

## Lancer le projet en développement

```bash
flutter pub get
flutter run
```

## Générer l'APK de release

```bash
flutter build apk --release
```

L'APK généré se trouve dans :

```
build/app/outputs/flutter-apk/app-release.apk
```

## Installer l'APK sur un téléphone Android

1. Activer le débogage USB sur le téléphone (Paramètres > Options pour les
   développeurs) et le connecter à l'ordinateur.
2. Vérifier que l'appareil est détecté :

   ```bash
   flutter devices
   ```

3. Installer l'APK directement :

   ```bash
   flutter install
   ```

   ou, avec ADB :

   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

Au premier lancement, l'application demande l'autorisation d'afficher des
notifications (obligatoire à partir d'Android 13) ainsi que l'autorisation
de planifier des alarmes exactes, nécessaire pour que les rappels
s'affichent précisément à l'heure choisie.
