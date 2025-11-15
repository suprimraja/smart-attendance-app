import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class StudentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String rollNumber;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  bool isActive;

  StudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    this.email,
    this.phone,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      email: map['email'],
      phone: map['phone'],
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }
}

class StudentModelAdapter extends TypeAdapter<StudentModel> {
  @override
  final int typeId = 1;

  @override
  StudentModel read(BinaryReader reader) {
    return StudentModel(
      id: reader.readString(),
      name: reader.readString(),
      rollNumber: reader.readString(),
      email: reader.readString(),
      phone: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      isActive: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, StudentModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.rollNumber);
    writer.writeString(obj.email ?? '');
    writer.writeString(obj.phone ?? '');
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeBool(obj.isActive);
  }
}
