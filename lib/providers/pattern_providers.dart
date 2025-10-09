import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../core/models/pattern_model.dart';

// Główny provider, który zarządza CAŁĄ listą wzorów
final patternProvider = StateNotifierProvider<PatternNotifier, List<PatternModel>>((ref) {
  return PatternNotifier();
});

// Provider dla listy ulubionych
final favoritePatternsProvider = Provider<List<PatternModel>>((ref) {
  final allPatterns = ref.watch(patternProvider);
  return allPatterns.where((pattern) => pattern.isFavourite).toList();
});

// --- WYSZUKIWARKA ---

// 1. Provider przechowujący wpisany tekst
final searchQueryProvider = StateProvider<String>((ref) => '');

// 2. Provider, który filtruje wzory na podstawie wyszukiwania
final filteredPatternsProvider = Provider<List<PatternModel>>((ref) {
  final allPatterns = ref.watch(patternProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) {
    return allPatterns; // Jeśli nic nie wpisano, pokaż wszystko
  }

  // Filtruj, ignorując wielkość liter
  return allPatterns
      .where((pattern) =>
          pattern.customName.toLowerCase().contains(query.toLowerCase()))
      .toList();
});

// ---------------------

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
