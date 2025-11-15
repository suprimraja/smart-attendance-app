import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class SubjectModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? code;

  @HiveField(3)
  String? description;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isActive;

  SubjectModel({
    required this.id,
    required this.name,
    this.code,
    this.description,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      code: map['code'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }
}

class SubjectModelAdapter extends TypeAdapter<SubjectModel> {
  @override
  final int typeId = 2;

  @override
  SubjectModel read(BinaryReader reader) {
    return SubjectModel(
      id: reader.readString(),
      name: reader.readString(),
      code: reader.readString(),
      description: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      isActive: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, SubjectModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.code ?? '');
    writer.writeString(obj.description ?? '');
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeBool(obj.isActive);
  }
}
