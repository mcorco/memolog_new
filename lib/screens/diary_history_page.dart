import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for Firebase
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // Import for date formatting
import 'edit_diary_entry_page.dart'; // Import EditDiaryEntryPage

class DiaryHistoryPage extends StatefulWidget {

  @override
  const DiaryHistoryPage({super.key});
  @override
  DiaryHistoryPageState createState() => DiaryHistoryPageState();
}

class DiaryHistoryPageState extends State<DiaryHistoryPage> {
  Stream<QuerySnapshot> _getEntriesStream() {
    return FirebaseFirestore.instance
        .collection('diaryEntries')
        .orderBy('date', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getEntriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading diary entries.'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No diary entries found.'));
          }

          final entries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index].data() as Map<String, dynamic>;
              final date = DateTime.parse(entry['date']);
              final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(entry['title']),
                  subtitle: Text(
                    '$formattedDate\n${entry['content']}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Add navigation to the EditDiaryEntryPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditDiaryEntryPage(
                          documentId: entries[index].id,
                          title: entry['title'],
                          content: entry['content'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
