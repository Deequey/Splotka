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
  late bool isFavourite;

  @HiveField(6)
  late String userNotes;

  @HiveField(7)
  late String thumbnailPath;

  @HiveField(8) // NOWE POLE
  late int currentRow;

  @HiveField(9)
  late String status; // 'planned', 'in_progress', 'finished'

  PatternModel({
    required this.id,
    required this.originalFileName,
    required this.customName,
    required this.localFilePath,
    required this.dateAdded,
    this.isFavourite = false,
    this.userNotes = '',
    this.thumbnailPath = '',
    this.currentRow = 0,
    this.status = 'planned',
  });

  static PatternModel createNew({
    required String id,
    required String fileName,
    required String path,
    required String thumbnailPath,
  }) {
    return PatternModel(
      id: id,
      originalFileName: fileName,
      customName: fileName.replaceAll('.pdf', '').trim(),
      localFilePath: path,
      dateAdded: DateTime.now().toString(),
      thumbnailPath: thumbnailPath,
      currentRow: 0,
      status: 'planned',
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
      thumbnailPath: '',
      currentRow: 0,
      status: 'planned',
    );
  }

  PatternModel copyWith({
    String? id,
    String? originalFileName,
    String? customName,
    String? localFilePath,
    String? dateAdded,
    bool? isFavourite,
    String? userNotes,
    String? thumbnailPath,
    int? currentRow,
    String? status,
  }) {
    return PatternModel(
      id: id ?? this.id,
      originalFileName: originalFileName ?? this.originalFileName,
      customName: customName ?? this.customName,
      localFilePath: localFilePath ?? this.localFilePath,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavourite: isFavourite ?? this.isFavourite,
      userNotes: userNotes ?? this.userNotes,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      currentRow: currentRow ?? this.currentRow,
      status: status ?? this.status,
    );
  }
}
