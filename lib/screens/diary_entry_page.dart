import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class DiaryEntryPage extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryEntryPage({super.key, required this.selectedDate});

  @override
  DiaryEntryPageState createState() => DiaryEntryPageState();
}
class DiaryEntryPageState extends State<DiaryEntryPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<XFile> images = [];
  String? documentId;

  @override
  void initState() {
    super.initState();
    _loadExistingEntry();
  }

  Future<void> _loadExistingEntry() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('diaryEntries')
          .where('date',
              isEqualTo: DateFormat("dd MMM yyyy HH:mm:ss 'GMT'")
                  .format(widget.selectedDate))
          .get();

      if (query.docs.isNotEmpty) {
        final entry = query.docs.first;
        documentId = entry.id;

        if (mounted) {
          setState(() {
            titleController.text = entry['title'];
            contentController.text = entry['content'];
            images = (entry['images'] as List<dynamic>)
                .map((path) => XFile(path.toString()))
                .toList();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load entry: $e')),
        );
      }
    }
  }

  Future<void> saveOrUpdateEntry() async {
    // Use current time for saving to make sure time is correctly recorded
    DateTime now = DateTime.now();
    String formattedDate = DateFormat("dd MMM yyyy HH:mm:ss 'GMT'").format(now);

    try {
      if (documentId == null) {
        // Save a new entry
        await FirebaseFirestore.instance.collection('diaryEntries').add({
          'title': titleController.text,
          'content': contentController.text,
          'date': formattedDate,
          'images': images.map((image) => image.path).toList(),
        });
      } else {
        // Update the existing entry
        await FirebaseFirestore.instance
            .collection('diaryEntries')
            .doc(documentId)
            .update({
          'title': titleController.text,
          'content': contentController.text,
          'images': images.map((image) => image.path).toList(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entry saved for $formattedDate')),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        );
      }
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedImages = await picker.pickMultiImage();
    if (mounted) {
      setState(() {
        images.addAll(pickedImages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(3, 169, 244, 1),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy GMT').format(widget.selectedDate),
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(3, 169, 244, 1),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: StreamBuilder<DateTime>(
                    stream: Stream.periodic(
                        const Duration(seconds: 1), (_) => DateTime.now()),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('');
                      }
                      return Text(
                        DateFormat('HH:mm:ss').format(DateTime.now()),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 32),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(3, 169, 244, 1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                icon: const Icon(Icons.add_a_photo, size: 80),
                onPressed: pickImage,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(3, 169, 244, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              ),
              onPressed: saveOrUpdateEntry,
              child: Text(
                documentId == null ? 'Save Entry' : 'Update Entry',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  DateFormat(String s) {}
}
