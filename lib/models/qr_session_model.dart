import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class QRSessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectId;

  @HiveField(2)
  String subjectName;

  @HiveField(3)
  DateTime startTime;

  @HiveField(4)
  DateTime? endTime;

  @HiveField(5)
  String qrData;

  @HiveField(6)
  bool isActive;

  QRSessionModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.startTime,
    this.endTime,
    required this.qrData,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'qrData': qrData,
      'isActive': isActive,
    };
  }

  factory QRSessionModel.fromMap(Map<String, dynamic> map) {
    return QRSessionModel(
      id: map['id'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      qrData: map['qrData'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}

class QRSessionModelAdapter extends TypeAdapter<QRSessionModel> {
  @override
  final int typeId = 3;

  @override
  QRSessionModel read(BinaryReader reader) {
    return QRSessionModel(
      id: reader.readString(),
      subjectId: reader.readString(),
      subjectName: reader.readString(),
      startTime: DateTime.parse(reader.readString()),
      endTime: reader.readString().isEmpty ? null : DateTime.parse(reader.readString()),
      qrData: reader.readString(),
      isActive: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, QRSessionModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.subjectId);
    writer.writeString(obj.subjectName);
    writer.writeString(obj.startTime.toIso8601String());
    writer.writeString(obj.endTime?.toIso8601String() ?? '');
    writer.writeString(obj.qrData);
    writer.writeBool(obj.isActive);
  }
}
