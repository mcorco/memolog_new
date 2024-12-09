import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DiaryEntryPage extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryEntryPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _DiaryEntryPageState createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isUpdateMode = false;
  String _confirmationMessage = '';

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

      if (docSnapshot.exists) {
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
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      final data = {
        'title': _titleController.text,
        'content': _contentController.text,
        'date': DateFormat('dd MMM yyyy hh:mm:ss').format(DateTime.now()) + ' GMT',
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

      setState(() {
        _isUpdateMode = true;
        _confirmationMessage = 'Entry saved for ${data['date']}';
      });

      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _confirmationMessage = '';
        });
      });
    } catch (e) {
      debugPrint('Error saving entry: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromRGBO(3, 169, 244, 1), // Light baby-blue background
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Header with Back Arrow, Title, and Date
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Diary Entry     ${DateFormat('dd MMM yyyy').format(widget.selectedDate)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Icon Section
              Center(
                child: Container(
                  width: 140,
                  height: 140,
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
                    onPressed: () {
                      // Future attach image implementation
                    },
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'Attach Images',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 174, 239),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveOrUpdateEntry,
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
                    child: Text(
                      _isUpdateMode ? 'Update' : 'Save',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
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
                    padding: const EdgeInsets.all(8.0),
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
      ),
    );
  }
}
