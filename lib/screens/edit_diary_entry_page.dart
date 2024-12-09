import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditDiaryEntryPage extends StatefulWidget {
  final String documentId;
  final String title;
  final String content;

  const EditDiaryEntryPage({
    super.key,
    required this.documentId,
    required this.title,
    required this.content,
  });

  @override
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
    try {
      // Format the date as dd.MM.yyyy GMT
      String formattedDate = DateFormat('dd.MM.yyyy').format(DateTime.now()) + " GMT";

      // Update the Firestore document
      await FirebaseFirestore.instance.collection('diaryEntries').doc(widget.documentId).update({
        'title': titleController.text,
        'content': contentController.text,
        'date': formattedDate,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating entry: $e')),
        );
      }
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
