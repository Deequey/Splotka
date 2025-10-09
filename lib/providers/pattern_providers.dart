import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../core/models/pattern_model.dart';

// Główny provider, który zarządza CAŁĄ listą wzorów
final patternProvider = StateNotifierProvider<PatternNotifier, List<PatternModel>>((ref) {
  return PatternNotifier();
});

// NOWY: Provider, który udostępnia przefiltrowaną listę (tylko ulubione)
// Automatycznie odświeży się, gdy zmienią się wzory w patternProvider
final favoritePatternsProvider = Provider<List<PatternModel>>((ref) {
  final allPatterns = ref.watch(patternProvider);
  return allPatterns.where((pattern) => pattern.isFavourite).toList();
});

class PatternNotifier extends StateNotifier<List<PatternModel>> {
  PatternNotifier() : super([]) {
    _loadPatterns();
  }

  void _loadPatterns() {
    final box = Hive.box<PatternModel>('patterns');
    state = box.values.toList();
  }

  Future<void> addPattern(PatternModel pattern) async {
    final box = Hive.box<PatternModel>('patterns');
    await box.put(pattern.id, pattern);
    _loadPatterns();
  }

  Future<void> removePattern(String id) async {
    final box = Hive.box<PatternModel>('patterns');
    await box.delete(id);
    _loadPatterns();
  }

  Future<void> updatePattern(PatternModel pattern) async {
    final box = Hive.box<PatternModel>('patterns');
    await box.put(pattern.id, pattern);
    _loadPatterns();
  }
}
