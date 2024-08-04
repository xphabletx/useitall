import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
      body: Padding(
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
            ),
            SwitchListTile(
              title: const Text('Lunch'),
              value: _isLunchOn,
              onChanged: (value) {
                setState(() {
                  _isLunchOn = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Dinner'),
              value: _isDinnerOn,
              onChanged: (value) {
                setState(() {
                  _isDinnerOn = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildCalendar(),
            ),
            if (_showTip)
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[300],
                child: Column(
                  children: [
                    const Text(
                      'Tip: Click and drag to highlight your planned days.',
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
          ],
        ),
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
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _rangeStart = null; // Important to clean those
            _rangeEnd = null;
          });
        }
      },
      onRangeSelected: (start, end, focusedDay) {
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
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        rangeStartDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        withinRangeDecoration: BoxDecoration(
          color: Colors.lightGreenAccent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}