import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/pattern_model.dart';
import '../../providers/pattern_providers.dart';

class DetailsScreen extends ConsumerWidget {
  final String patternId;

  const DetailsScreen({super.key, required this.patternId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patterns = ref.watch(patternProvider);
    final pattern = patterns.firstWhere((p) => p.id == patternId, orElse: () => PatternModel.empty());

    return Scaffold(
      appBar: AppBar(
        title: Text(pattern.customName.isNotEmpty ? pattern.customName : 'Nie znaleziono wzoru'),
      ),
      body: Center(
        child: pattern.customName.isNotEmpty
            ? Text('Szczegóły wzoru: ${pattern.customName}')
            : const Text('Wybierz wzór, aby zobaczyć szczegóły.'),
      ),
    );
  }
}
