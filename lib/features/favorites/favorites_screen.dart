import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pattern_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritePatterns = ref.watch(patternProvider).where((p) => p.isFavourite == 'true').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione Wzory'),
      ),
      body: favoritePatterns.isEmpty
          ? const Center(
              child: Text('Brak ulubionych wzorów.'),
            )
          : ListView.builder(
              itemCount: favoritePatterns.length,
              itemBuilder: (context, index) {
                final pattern = favoritePatterns[index];
                return ListTile(
                  title: Text(pattern.customName),
                  subtitle: Text(pattern.originalFileName),
                );
              },
            ),
    );
  }
}
