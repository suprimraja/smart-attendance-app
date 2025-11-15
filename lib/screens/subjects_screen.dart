import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/subject_provider.dart';
import '../models/subject_model.dart';

class SubjectsScreen extends StatefulWidget {
  @override
  _SubjectsScreenState createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subjects"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddSubjectDialog(context),
          ),
        ],
      ),
      body: Consumer<SubjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          var subjects = provider.subjects;
          
          // Filter subjects based on search
          if (_searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            subjects = subjects.where((s) {
              return s.name.toLowerCase().contains(query) ||
                  (s.code?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          if (subjects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No subjects found",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tap + to add a subject",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search subjects...",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.book),
                        ),
                        title: Text(subject.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (subject.code != null) Text("Code: ${subject.code}"),
                            if (subject.description != null)
                              Text(subject.description!),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditSubjectDialog(context, subject),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(context, subject),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add Subject"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Subject Name *"),
                autofocus: true,
              ),
              SizedBox(height: 12),
              TextField(
                controller: codeController,
                decoration: InputDecoration(labelText: "Subject Code"),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Subject name is required")),
                );
                return;
              }

              final provider = Provider.of<SubjectProvider>(context, listen: false);
              final subject = SubjectModel(
                id: Uuid().v4(),
                name: nameController.text.trim(),
                code: codeController.text.trim().isEmpty
                    ? null
                    : codeController.text.trim(),
                description: descController.text.trim().isEmpty
                    ? null
                    : descController.text.trim(),
                createdAt: DateTime.now(),
              );

              final success = await provider.addSubject(subject);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Subject added successfully")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? "Failed to add subject")),
                );
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditSubjectDialog(BuildContext context, SubjectModel subject) {
    final nameController = TextEditingController(text: subject.name);
    final codeController = TextEditingController(text: subject.code ?? '');
    final descController = TextEditingController(text: subject.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Subject"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Subject Name *"),
              ),
              SizedBox(height: 12),
              TextField(
                controller: codeController,
                decoration: InputDecoration(labelText: "Subject Code"),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Subject name is required")),
                );
                return;
              }

              final provider = Provider.of<SubjectProvider>(context, listen: false);
              subject.name = nameController.text.trim();
              subject.code = codeController.text.trim().isEmpty
                  ? null
                  : codeController.text.trim();
              subject.description = descController.text.trim().isEmpty
                  ? null
                  : descController.text.trim();

              final success = await provider.updateSubject(subject);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Subject updated successfully")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? "Failed to update subject")),
                );
              }
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SubjectModel subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Subject"),
        content: Text("Are you sure you want to delete ${subject.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<SubjectProvider>(context, listen: false);
              await provider.deleteSubject(subject.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Subject deleted")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }
}

