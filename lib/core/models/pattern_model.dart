import 'package:hive/hive.dart';

part 'pattern_model.g.dart'; //jesli sie swieci to zignoruj generuje sie w tle!!

@HiveType(typeId: 0)
class PatternModel extends HiveObject {
  @HiveField(0)
  late String id; //unique id

  @HiveField(1)
  late String originalFileName; //nazwa pliku z dysku

  @HiveField(2)
  late String customName; //nazwa uzytkownika

  @HiveField(3)
  late String localFilePath; //url do pdf w pamieci

  @HiveField(4)
  late String dateAdded;

  @HiveField(5)
  late String isFavourite;

  @HiveField(6)
  late String userNotes;

  PatternModel({
    required this.id,
    required this.originalFileName,
    required this.customName,
    required this.localFilePath,
    required this.dateAdded,
    this.isFavourite = 'false',
    this.userNotes = '',
  });

  static PatternModel createNew({
    required String fileName,
    required String path
  }) {
    return PatternModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalFileName: fileName,
      customName: fileName.split('.').first,
      localFilePath: path,
      dateAdded: DateTime.now().toString(),
    );
  }
}