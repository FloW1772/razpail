import 'package:flutter/material.dart';

/// Palette d'avatars dérivée d'un nom : couleur stable pour une même
/// personne, choisie parmi des teintes harmonieuses avec le thème.
const List<Color> _avatarPalette = [
  Color(0xFF4B2E83),
  Color(0xFFFF8C69),
  Color(0xFF2E7D6B),
  Color(0xFFB4548A),
  Color(0xFF3D5A99),
  Color(0xFFC9852C),
];

Color avatarColorFor(String name) {
  if (name.isEmpty) return _avatarPalette.first;
  final index = name.codeUnits.fold<int>(0, (sum, c) => sum + c) %
      _avatarPalette.length;
  return _avatarPalette[index];
}

String initialsFor(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  final first = parts.first.isNotEmpty ? parts.first.substring(0, 1) : '';
  final last = parts.length > 1 && parts.last.isNotEmpty
      ? parts.last.substring(0, 1)
      : '';
  return (first + last).toUpperCase();
}
