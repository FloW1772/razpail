import 'package:flutter/material.dart';

void main() {
  runApp(const MemoAnniversairesApp());
}

/// Point d'entrée temporaire de l'application, complété au fil des étapes
/// suivantes (stockage, notifications, écrans).
class MemoAnniversairesApp extends StatelessWidget {
  const MemoAnniversairesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mémo Anniversaires',
      home: Scaffold(
        body: Center(child: Text('Mémo Anniversaires')),
      ),
    );
  }
}
