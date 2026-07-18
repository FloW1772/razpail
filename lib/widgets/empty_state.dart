import 'package:flutter/material.dart';

/// Illustration et message chaleureux affichés quand aucun rappel n'existe.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.18),
                    scheme.secondary.withValues(alpha: 0.18),
                  ],
                ),
              ),
              child: Icon(
                Icons.cake_rounded,
                size: 64,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Aucun anniversaire pour l\'instant',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Ajoutez un premier rappel pour ne plus jamais oublier '
              'une date qui compte pour vous.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
