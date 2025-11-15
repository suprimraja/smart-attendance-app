import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';
import '../providers/subject_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analytics & Statistics"),
      ),
      body: Consumer3<AttendanceProvider, StudentProvider, SubjectProvider>(
        builder: (context, attendanceProvider, studentProvider, subjectProvider, child) {
          final stats = attendanceProvider.stats;
          final attendanceBySubject = stats['attendanceBySubject'] as Map<String, int>? ?? {};
          final attendanceByStudent = stats['attendanceByStudent'] as Map<String, int>? ?? {};

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: "Total Attendance",
                        value: "${stats['totalAttendance']}",
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: "Today",
                        value: "${stats['todayAttendance']}",
                        icon: Icons.today,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: "Students",
                        value: "${stats['totalStudents']}",
                        icon: Icons.people,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: "Subjects",
                        value: "${stats['totalSubjects']}",
                        icon: Icons.book,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Attendance by Subject Chart
                if (attendanceBySubject.isNotEmpty) ...[
                  Text(
                    "Attendance by Subject",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: attendanceBySubject.values.isEmpty
                                ? 10
                                : attendanceBySubject.values.reduce((a, b) => a > b ? a : b).toDouble() + 5,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < attendanceBySubject.keys.length) {
                                      final subject = attendanceBySubject.keys.elementAt(index);
                                      return Padding(
                                        padding: EdgeInsets.only(top: 8),
                                        child: Text(
                                          subject.length > 8 ? subject.substring(0, 8) : subject,
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: attendanceBySubject.entries.toList().asMap().entries.map((entry) {
                              final index = entry.key;
                              final subjectEntry = entry.value;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: subjectEntry.value.toDouble(),
                                    color: Colors.blue,
                                    width: 20,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],

                // Top Students
                if (attendanceByStudent.isNotEmpty) ...[
                  Text(
                    "Top Students by Attendance",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: (() {
                        final sorted = attendanceByStudent.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));
                        return sorted.take(5).map((entry) {
                          final student = studentProvider.getStudentById(entry.key);
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                student?.name[0].toUpperCase() ?? '?',
                              ),
                            ),
                            title: Text(student?.name ?? 'Unknown'),
                            subtitle: Text("Roll: ${student?.rollNumber ?? 'N/A'}"),
                            trailing: Chip(
                              label: Text("${entry.value}"),
                              backgroundColor: Colors.blue.withOpacity(0.2),
                            ),
                          );
                        }).toList();
                      })(),
                    ),
                  ),
                  SizedBox(height: 24),
                ],

                // Subject List
                Text(
                  "Subject Statistics",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 12),
                ...attendanceBySubject.entries.map((entry) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.book, color: Colors.purple),
                      title: Text(entry.key),
                      trailing: Chip(
                        label: Text("${entry.value}"),
                        backgroundColor: Colors.purple.withOpacity(0.2),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

