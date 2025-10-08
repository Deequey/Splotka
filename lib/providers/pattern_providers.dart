import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/pattern_model.dart';

final patternProvider = StateNotifierProvider<PatternNotifier, List<PatternModel>>((ref) {
  return PatternNotifier();
});

class PatternNotifier extends StateNotifier<List<PatternModel>> {
  PatternNotifier() : super([]);

  void addPattern(PatternModel pattern) {
    state = [...state, pattern];
  }

  void removePattern(String id) {
    state = state.where((pattern) => pattern.id != id).toList();
  }
}
