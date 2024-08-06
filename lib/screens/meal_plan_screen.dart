import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'suggestions_screen.dart';

class MealPlanScreen extends StatefulWidget {
  final String userName;

  const MealPlanScreen({super.key, required this.userName});

  @override
  MealPlanScreenState createState() => MealPlanScreenState();
}

class MealPlanScreenState extends State<MealPlanScreen> {
  bool _isBreakfastOn = true;
  bool _isLunchOn = true;
  bool _isDinnerOn = true;
  final DateTime _today = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _showTip = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Meal Plan'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Meal Types',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Breakfast'),
                  value: _isBreakfastOn,
                  onChanged: (value) {
                    setState(() {
                      _isBreakfastOn = value;
                    });
                  },
                  activeColor: Colors.orange,
                ),
                SwitchListTile(
                  title: const Text('Lunch'),
                  value: _isLunchOn,
                  onChanged: (value) {
                    setState(() {
                      _isLunchOn = value;
                    });
                  },
                  activeColor: Colors.orange,
                ),
                SwitchListTile(
                  title: const Text('Dinner'),
                  value: _isDinnerOn,
                  onChanged: (value) {
                    setState(() {
                      _isDinnerOn = value;
                    });
                  },
                  activeColor: Colors.orange,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildCalendar(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_rangeStart != null && _rangeEnd != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SuggestionsScreen(
                            userName: widget.userName,
                            startDate: _rangeStart!,
                            endDate: _rangeEnd!,
                          ),
                        ),
                      );
                    } else {
                      _showError('Please select start and end dates for the meal plan.');
                    }
                  },
                  child: const Text('Get Meal Suggestions'),
                ),
              ],
            ),
          ),
          if (_showTip)
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[300],
                child: Column(
                  children: [
                    const Text(
                      'Highlight your start and end dates for the meal plan, like you\'re booking a food holiday!',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showTip = false;
                        });
                      },
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2000, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay ?? _today,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      onDaySelected: (selectedDay, focusedDay) {
        if (selectedDay.isBefore(_today)) {
          _showError('You cannot plan meals before today\'s date.');
          return;
        }
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _rangeStart = null;
            _rangeEnd = null;
          });
        }
      },
      onRangeSelected: (start, end, focusedDay) {
        if (start!.isBefore(_today) || (end != null && end.isBefore(_today))) {
          _showError('You cannot plan meals before today\'s date.');
          return;
        }
        setState(() {
          _selectedDay = null;
          _focusedDay = focusedDay;
          _rangeStart = start;
          _rangeEnd = end;
        });
      },
      calendarFormat: CalendarFormat.month,
      rangeSelectionMode: RangeSelectionMode.enforced,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          color: Colors.white,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.grey[800],
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
        ),
        rangeStartDecoration: BoxDecoration(
          color: Colors.grey[800],
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: Colors.grey[800],
          shape: BoxShape.circle,
        ),
        withinRangeDecoration: BoxDecoration(
          color: Colors.grey[600],
          shape: BoxShape.circle,
        ),
        withinRangeTextStyle: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}