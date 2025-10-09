import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../core/models/pattern_model.dart';

final patternProvider = StateNotifierProvider<PatternNotifier, List<PatternModel>>((ref) {
  return PatternNotifier();
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
}
