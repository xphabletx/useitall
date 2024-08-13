import 'package:flutter/material.dart';

import '../utilities/short_date.dart'; // Import the short_date utility

class DateWheel extends StatefulWidget {
  final List<DateTime> dates;
  final DateTime? focusedDate;
  final void Function(int) onSelectedItemChanged;
  final void Function(DateTime) onDateTap;

  const DateWheel({
    super.key,
    required this.dates,
    required this.focusedDate,
    required this.onSelectedItemChanged,
    required this.onDateTap,
  });

  @override
  _DateWheelState createState() => _DateWheelState();
}

class _DateWheelState extends State<DateWheel> {
  late ScrollController _scrollController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.dates.indexOf(widget.focusedDate ?? widget.dates.first);
    _scrollController = ScrollController(
      initialScrollOffset: _currentIndex * 80.0, // Assuming each item width is 80
    );
  }

  void _onDateTap(int index) {
    setState(() {
      _currentIndex = index;
      widget.onDateTap(widget.dates[index]);
      _scrollController.animateTo(
        index * 80.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Adjust based on your design
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.dates.length,
        itemBuilder: (context, index) {
          final date = widget.dates[index];
          final isFocused = index == _currentIndex;
          return GestureDetector(
            onTap: () => _onDateTap(index),
            child: Container(
              width: 80, // Set the width of each date item
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFocused ? Colors.orange.shade200 : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${shortWeekday(date)}\n${date.day}\n${shortMonth(date)}', // Correctly formatted date
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isFocused ? 18 : 14,
                  color: isFocused ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}