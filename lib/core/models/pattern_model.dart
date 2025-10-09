import 'package:hive/hive.dart';

part 'pattern_model.g.dart'; // Jeśli się świeci, zignoruj – generuje się w tle!

@HiveType(typeId: 0)
class PatternModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String originalFileName;

  @HiveField(2)
  late String customName;

  @HiveField(3)
  late String localFilePath;

  @HiveField(4)
  late String dateAdded;

  @HiveField(5)
  late bool isFavourite; // ZMIANA: String -> bool

  @HiveField(6)
  late String userNotes;

  PatternModel({
    required this.id,
    required this.originalFileName,
    required this.customName,
    required this.localFilePath,
    required this.dateAdded,
    this.isFavourite = false, // ZMIANA: 'false' -> false
    this.userNotes = '',
  });

  static PatternModel createNew({
    required String id,
    required String fileName,
    required String path,
  }) {
    return PatternModel(
      id: id,
      originalFileName: fileName,
      customName: fileName.replaceAll('.pdf', '').trim(),
      localFilePath: path,
      dateAdded: DateTime.now().toString(),
    );
  }

  static PatternModel empty() {
    return PatternModel(
      id: '',
      originalFileName: '',
      customName: '',
      localFilePath: '',
      dateAdded: '',
      isFavourite: false,
    );
  }

  PatternModel copyWith({
    String? id,
    String? originalFileName,
    String? customName,
    String? localFilePath,
    String? dateAdded,
    bool? isFavourite, // ZMIANA: String? -> bool?
    String? userNotes,
  }) {
    return PatternModel(
      id: id ?? this.id,
      originalFileName: originalFileName ?? this.originalFileName,
      customName: customName ?? this.customName,
      localFilePath: localFilePath ?? this.localFilePath,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavourite: isFavourite ?? this.isFavourite,
      userNotes: userNotes ?? this.userNotes,
    );
  }
}
