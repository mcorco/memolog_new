import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb

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
  final List<String> _uploadedImageUrls = [];
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
          _uploadedImageUrls.clear();
          _uploadedImageUrls.addAll(
              (data['images'] as List<dynamic>?)?.cast<String>() ?? []);
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

      // Upload images to Firebase Storage and get their URLs
      final imageUrls = await _uploadImages();

      final data = {
        'title': _titleController.text,
        'content': _contentController.text,
        'date': formattedTimestamp,
        'images': imageUrls, // Save image URLs to Firestore
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

  Future<List<String>> _uploadImages() async {
    final List<String> uploadedUrls = [];

    for (var i = 0; i < _imageList.length; i++) {
      final imageFile = _imageList[i];
      if (imageFile != null) {
        final fileName =
            '${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}_image_$i';
        final ref = FirebaseStorage.instance
            .ref()
            .child('diaryEntries/${widget.selectedDate}/$fileName');

        try {
          final uploadTask = await ref.putFile(imageFile);
          final imageUrl = await uploadTask.ref.getDownloadURL();
          uploadedUrls.add(imageUrl);
        } catch (e) {
          debugPrint('Error uploading image: $e');
        }
      }
    }

    return uploadedUrls;
  }

  Future<void> _attachImage(int index) async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        setState(() {
          _imageList[index] = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _imageList[index] = null;
    });
  }

  Widget _buildImageWidget(File? imageFile, int index) {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.lightBlueAccent, width: 2),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageFile != null
                ? (kIsWeb
                    ? Image.network(
                        imageFile.path,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      )
                    : Image.file(
                        imageFile,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ))
                : const Icon(Icons.add_photo_alternate, color: Colors.grey),
          ),
        ),
        if (imageFile != null)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _deleteImage(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
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
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color.fromRGBO(3, 169, 244, 1),
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
                Text(
                  "Diary Entry: ${DateFormat('dd MMM yyyy').format(widget.selectedDate)}",
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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromRGBO(3, 169, 244, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(2, (index) {
                    return GestureDetector(
                      onTap: () => _attachImage(index),
                      child: _buildImageWidget(_imageList[index], index),
                    );
                  }),
                  Container(
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
                        width: 8,
                      ),
                    ),
                  ),
                  ...List.generate(2, (index) {
                    return GestureDetector(
                      onTap: () => _attachImage(index + 2),
                      child: _buildImageWidget(_imageList[index + 2], index + 2),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
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
              const Spacer(),
              if (_confirmationMessage.isNotEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),
                    child: Text(
                      _confirmationMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
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
