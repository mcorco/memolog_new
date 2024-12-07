// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:table_calendar/table_calendar.dart';
// ignore: depend_on_referenced_packages
import 'package:logger/logger.dart';
import 'diary_entry_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Map<DateTime, List<dynamic>> events = {};
  CalendarFormat calendarFormat = CalendarFormat.month;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('diaryEntries').get();
      setState(() {
        events.clear();
        for (var doc in snapshot.docs) {
          DateTime date = (doc['date'] as Timestamp).toDate().toLocal();
          events[date] = ['Entry exists'];
        }
      });
      logger.i("Loaded diary entries successfully.");
    } catch (e) {
      logger.e("Error loading diary entries: $e");
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryEntryPage(selectedDate: selectedDay),
      ),
    ).then((_) {
      _loadEntries();
    });
  }

  void _onLogoutPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MemoLog Calendar'),
        backgroundColor: const Color.fromRGBO(3, 169, 244, 1),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(3, 169, 244, 1),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Diary Icon Image
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('lib/images/leather_diary.png'),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.lightBlueAccent,
                      width: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Calendar Widget
                TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  calendarFormat: calendarFormat,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  eventLoader: (day) => events[day] ?? [],
                  onDaySelected: _onDaySelected,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: const Color.fromARGB(255, 4, 237, 12),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: const Color.fromRGBO(3, 169, 244, 1),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: const Color.fromARGB(255, 4, 237, 12),
                      shape: BoxShape.circle,
                    ),
                    outsideTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    defaultTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    weekendTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    todayTextStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                    selectedTextStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    formatButtonVisible: false,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      if (events[day] != null && events[day]!.isNotEmpty) {
                        return Container(
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(3, 169, 244, 1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Exit Button
                ElevatedButton.icon(
                  onPressed: _onLogoutPressed,
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  label: const Text('Exit', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 4, 237, 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
