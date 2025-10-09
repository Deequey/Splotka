import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/pattern_model.dart';
import '../../core/theme.dart';
import '../../providers/pattern_providers.dart';
import '../details/details_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Używamy nowego providera, który dostarcza tylko ulubione wzory
    final favoritePatterns = ref.watch(favoritePatternsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione Wzory'),
      ),
      body: favoritePatterns.isEmpty
          ? const Center(
              child: Text('Brak ulubionych wzorów. Dodaj je, klikając gwiazdkę.', style: TextStyle(color: kBrown)),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: favoritePatterns.length,
              itemBuilder: (context, index) {
                final pattern = favoritePatterns[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(patternId: pattern.id),
                      ),
                    );
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(child: Icon(Icons.picture_as_pdf, size: 50, color: kBrown.withAlpha(128))),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            pattern.customName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
