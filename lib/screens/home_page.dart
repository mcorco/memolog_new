import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'diary_entry_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _firestoreTestResult = '';

  @override
  void initState() {
    super.initState();
    _testFirestoreConnection();
  }

  Future<void> _testFirestoreConnection() async {
    try {
      await FirebaseFirestore.instance.collection('testCollection').doc('testDoc').set({
        'message': 'Hello, Firestore!',
        'timestamp': DateTime.now().toIso8601String(),
      });

      final docSnapshot = await FirebaseFirestore.instance
          .collection('testCollection')
          .doc('testDoc')
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        setState(() {
          _firestoreTestResult = 'Firestore test successful: ${data?['message']}';
        });
      } else {
        setState(() {
          _firestoreTestResult = 'Test document not found!';
        });
      }
    } catch (e) {
      setState(() {
        _firestoreTestResult = 'Error connecting to Firestore: $e';
      });
    }
  }

  Future<void> _showYearPicker() async {
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromRGBO(3, 169, 244, 1), // Baby-blue background
          child: SizedBox(
            width: 120,
            height: 300,
            child: ListView.builder(
              itemCount: 500,
              itemBuilder: (BuildContext context, int index) {
                final year = 1900 + index;
                return ListTile(
                  title: Center(
                    child: Text(
                      year.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(year);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null) {
      setState(() {
        _focusedDay = DateTime(selectedYear, _focusedDay.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromRGBO(3, 169, 244, 1),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Title Section
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      "MemoLog Calendar",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Month and Year Navigation with Year Picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _showYearPicker,
                      child: Text(
                        "${_focusedDay.year} - ${_focusedDay.month.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(1900, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    startingDayOfWeek: StartingDayOfWeek.monday, // Start weeks on Monday
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryEntryPage(selectedDate: selectedDay),
                        ),
                      );
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(color: Colors.white),
                      outsideTextStyle: TextStyle(color: Colors.grey),
                      weekendTextStyle: TextStyle(color: Colors.white),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Firestore Test Result
              if (_firestoreTestResult.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _firestoreTestResult,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Exit Button Section
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Exit",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 174, 239),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 40.0,
                    ),
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
