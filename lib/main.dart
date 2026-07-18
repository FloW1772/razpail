import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/reminder_repository.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final repository = await ReminderRepository.open();

  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();
  // Reprogramme toutes les alarmes, notamment après un redémarrage du
  // téléphone où AlarmManager perd les alarmes en attente.
  await NotificationService.instance.rescheduleAll(repository.sortedReminders);

  await initializeDateFormatting('fr_FR');

  runApp(MemoAnniversairesApp(repository: repository));
}

/// Point d'entrée de l'application : branchement du stockage local, du
/// thème Material 3 clair/sombre automatique et de l'écran principal.
class MemoAnniversairesApp extends StatelessWidget {
  const MemoAnniversairesApp({super.key, required this.repository});

  final ReminderRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReminderRepository>.value(
      value: repository,
      child: MaterialApp(
        title: 'Mémo Anniversaires',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
