import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure this is present
// Removed unused import 'dart:math';

class MealPlanScreen extends StatefulWidget {
  final String userName;

  const MealPlanScreen({Key? key, required this.userName}) : super(key: key);

  @override
  MealPlanScreenState createState() => MealPlanScreenState();
}

class MealPlanScreenState extends State<MealPlanScreen> {
  bool _isBreakfastOn = true;
  bool _isLunchOn = true;
  bool _isDinnerOn = true;
  final DateTime _today = DateTime.now(); // Marked as final
  DateTime? _startDate;
  DateTime? _endDate;
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
    DateTime firstDayOfMonth = DateTime(_today.year, _today.month, 1);
    int daysInMonth = DateTime(_today.year, _today.month + 1, 0).day;

    List<Widget> calendarDays = [];
    for (int i = 0; i < daysInMonth; i++) {
      DateTime date = firstDayOfMonth.add(Duration(days: i));
      calendarDays.add(
        GestureDetector(
          onTapDown: (_) {
            _onDateTapDown(date);
          },
          onTapUp: (_) {
            _onDateTapUp(date);
          },
          child: Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: _getDateBackgroundColor(date),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                DateFormat('d').format(date),
                style: TextStyle(
                  color: date.isBefore(_today) ? Colors.grey : Colors.black,
                  fontWeight: date == _today ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      children: calendarDays,
    );
  }

  void _onDateTapDown(DateTime date) {
    if (date.isBefore(_today)) {
      _showError('You cannot plan meals before today\'s date.');
      return;
    }
    setState(() {
      _startDate = date;
      _endDate = date;
    });
  }

  void _onDateTapUp(DateTime date) {
    if (date.isBefore(_today)) {
      _showError('You cannot plan meals before today\'s date.');
      return;
    }
    setState(() {
      _endDate = date;
    });
  }

  Color _getDateBackgroundColor(DateTime date) {
    if (date == _today) {
      return Colors.grey[400]!;
    }
    if (_startDate != null && _endDate != null && date.isAfter(_startDate!) && date.isBefore(_endDate!)) {
      return Colors.grey[300]!;
    }
    return Colors.white;
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