import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class AttendanceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String studentId;

  @HiveField(2)
  String studentName;

  @HiveField(3)
  String rollNumber;

  @HiveField(4)
  String subjectId;

  @HiveField(5)
  String subjectName;

  @HiveField(6)
  DateTime timestamp;

  @HiveField(7)
  String? qrCodeData;

  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.subjectId,
    required this.subjectName,
    required this.timestamp,
    this.qrCodeData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'rollNumber': rollNumber,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'timestamp': timestamp.toIso8601String(),
      'qrCodeData': qrCodeData,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      qrCodeData: map['qrCodeData'],
    );
  }
}

// Manual adapter
class AttendanceModelAdapter extends TypeAdapter<AttendanceModel> {
  @override
  final int typeId = 0;

  @override
  AttendanceModel read(BinaryReader reader) {
    return AttendanceModel(
      id: reader.readString(),
      studentId: reader.readString(),
      studentName: reader.readString(),
      rollNumber: reader.readString(),
      subjectId: reader.readString(),
      subjectName: reader.readString(),
      timestamp: DateTime.parse(reader.readString()),
      qrCodeData: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.studentId);
    writer.writeString(obj.studentName);
    writer.writeString(obj.rollNumber);
    writer.writeString(obj.subjectId);
    writer.writeString(obj.subjectName);
    writer.writeString(obj.timestamp.toIso8601String());
    writer.writeString(obj.qrCodeData ?? '');
  }
}
