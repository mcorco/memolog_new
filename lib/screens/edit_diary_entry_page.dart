import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDiaryEntryPage extends StatefulWidget {
  final String documentId;
  final String title;
  final String content;

  const EditDiaryEntryPage({
    super.key, // Add a key parameter
    required this.documentId,
    required this.title,
    required this.content,
  }); // Call the superclass constructor with the key

  @override
  // ignore: library_private_types_in_public_api
  _EditDiaryEntryPageState createState() => _EditDiaryEntryPageState();
}

class _EditDiaryEntryPageState extends State<EditDiaryEntryPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    contentController = TextEditingController(text: widget.content);
  }

  Future<void> updateEntry() async {
    await FirebaseFirestore.instance.collection('diaryEntries').doc(widget.documentId).update({
      'title': titleController.text,
      'content': contentController.text,
      'date': DateTime.now().toIso8601String(), // Update date to current time
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entry updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Diary Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateEntry,
              child: const Text('Update Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
