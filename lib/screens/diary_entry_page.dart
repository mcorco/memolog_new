import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DiaryEntryPage extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryEntryPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _DiaryEntryPageState createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<File?> _imageList = List.filled(4, null); // Limit to 4 images
  bool _isUpdateMode = false;
  String _confirmationMessage = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingEntry();
  }

  Future<void> _loadExistingEntry() async {
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      final docSnapshot = await FirebaseFirestore.instance
          .collection('diaryEntries')
          .doc(dateKey)
          .get();

      if (docSnapshot.exists && mounted) {
        final data = docSnapshot.data()!;
        setState(() {
          _titleController.text = data['title'] ?? '';
          _contentController.text = data['content'] ?? '';
          _isUpdateMode = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading entry: $e');
    }
  }

  Future<void> _saveOrUpdateEntry() async {
    if (_isSaving) return; // Prevent duplicate saves
    setState(() {
      _isSaving = true;
    });

    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      final currentTime = DateTime.now();
      final formattedTimestamp =
          DateFormat('dd MMM yyyy @ HH:mm:ss').format(currentTime) + ' GMT';

      final data = {
        'title': _titleController.text,
        'content': _contentController.text,
        'date': formattedTimestamp,
      };

      if (_isUpdateMode) {
        await FirebaseFirestore.instance
            .collection('diaryEntries')
            .doc(dateKey)
            .update(data);
      } else {
        await FirebaseFirestore.instance
            .collection('diaryEntries')
            .doc(dateKey)
            .set(data);
      }

      if (mounted) {
        setState(() {
          _isUpdateMode = true;
          _confirmationMessage = 'Entry saved for $formattedTimestamp';
        });
      }

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _confirmationMessage = '';
          });
        }
      });
    } catch (e) {
      debugPrint('Error saving entry: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _attachImage(int index) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        setState(() {
          _imageList[index] = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Match AppBar height
        child: Container(
          color: const Color.fromRGBO(3, 169, 244, 1), // Match AppBar color
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  tooltip: 'Back',
                ),
                const SizedBox(width: 8),
                Text(
                  'Diary Entry: ${DateFormat('dd MMM yyyy').format(widget.selectedDate)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(3, 169, 244, 1), // Match background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Image Slots and Central Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(2, (index) {
                  return GestureDetector(
                    onTap: () => _attachImage(index),
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.lightBlueAccent, width: 2),
                        borderRadius: BorderRadius.circular(10),
                        image: _imageList[index] != null
                            ? DecorationImage(
                                image: FileImage(_imageList[index]!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.white,
                      ),
                      child: _imageList[index] == null
                          ? const Icon(Icons.add_photo_alternate, color: Colors.grey)
                          : null,
                    ),
                  );
                }),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage('lib/images/leather_diary.png'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.lightBlueAccent,
                      width: 4,
                    ),
                  ),
                ),
                ...List.generate(2, (index) {
                  return GestureDetector(
                    onTap: () => _attachImage(index + 2),
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.lightBlueAccent, width: 2),
                        borderRadius: BorderRadius.circular(10),
                        image: _imageList[index + 2] != null
                            ? DecorationImage(
                                image: FileImage(_imageList[index + 2]!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.white,
                      ),
                      child: _imageList[index + 2] == null
                          ? const Icon(Icons.add_photo_alternate, color: Colors.grey)
                          : null,
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            // Title Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveOrUpdateEntry,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _isUpdateMode ? 'Update' : 'Save',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 174, 239),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 40.0,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Confirmation Message
            if (_confirmationMessage.isNotEmpty)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.black54,
                  child: Text(
                    _confirmationMessage,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
