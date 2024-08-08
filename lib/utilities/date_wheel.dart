import 'package:flutter/material.dart';

class DateWheel extends StatefulWidget {
  final List<DateTime> dates;
  final DateTime? focusedDate;
  final void Function(int) onSelectedItemChanged;
  final void Function(DateTime) onDateTap;
  final bool isHorizontal;

  const DateWheel({
    super.key,
    required this.dates,
    required this.focusedDate,
    required this.onSelectedItemChanged,
    required this.onDateTap,
    this.isHorizontal = false,
  });

  @override
  _DateWheelState createState() => _DateWheelState();
}

class _DateWheelState extends State<DateWheel> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
      initialItem: widget.dates.indexOf(widget.focusedDate ?? widget.dates.first),
    );
  }

  @override
  void didUpdateWidget(covariant DateWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedDate != oldWidget.focusedDate) {
      _scrollController.jumpToItem(widget.dates.indexOf(widget.focusedDate ?? widget.dates.first));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHorizontal) {
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.dates.length,
          itemBuilder: (context, index) {
            final date = widget.dates[index];
            return GestureDetector(
              onTap: () {
                widget.onDateTap(date);
                _scrollController.animateToItem(
                  index,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                alignment: Alignment.center,
                                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _shortWeekday(date),
                      style: TextStyle(
                        color: widget.focusedDate == date ? Colors.black : Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: widget.focusedDate == date ? Colors.grey[800] : Colors.transparent,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: widget.focusedDate == date ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      _shortMonth(date),
                      style: TextStyle(
                        color: widget.focusedDate == date ? Colors.black : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return SizedBox(
        width: 100,
        child: ListWheelScrollView.useDelegate(
          itemExtent: 60,
          diameterRatio: 1.5,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: widget.onSelectedItemChanged,
          controller: _scrollController,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: widget.dates.length,
            builder: (context, index) {
              final date = widget.dates[index];
              return GestureDetector(
                onTap: () {
                  widget.onDateTap(date);
                  _scrollController.animateToItem(
                    index,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _shortWeekday(date),
                        style: TextStyle(
                          color: widget.focusedDate == date ? Colors.black : Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: widget.focusedDate == date ? Colors.grey[800] : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: widget.focusedDate == date ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        _shortMonth(date),
                        style: TextStyle(
                          color: widget.focusedDate == date ? Colors.black : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  String _shortWeekday(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  String _shortMonth(DateTime date) {
    switch (date.month) {
      case DateTime.january:
        return 'Jan';
      case DateTime.february:
        return 'Feb';
      case DateTime.march:
        return 'Mar';
      case DateTime.april:
        return 'Apr';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'Jun';
      case DateTime.july:
        return 'Jul';
      case DateTime.august:
        return 'Aug';
      case DateTime.september:
        return 'Sep';
      case DateTime.october:
        return 'Oct';
      case DateTime.november:
        return 'Nov';
      case DateTime.december:
        return 'Dec';
      default:
        return '';
    }
  }
}