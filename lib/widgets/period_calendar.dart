import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/period_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/date_utils.dart' as custom_utils;

class PeriodCalendar extends StatefulWidget {
  const PeriodCalendar({super.key});

  @override
  State<PeriodCalendar> createState() => _PeriodCalendarState();
}

class _PeriodCalendarState extends State<PeriodCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<PeriodProvider>(
      builder: (context, periodProvider, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return _selectedDay != null &&
                    custom_utils.PeriodDateUtils.isSameDay(_selectedDay!, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                // Period days
                markerDecoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                // Ovulation day
                markersMaxCount: 3,
                // Today style
                todayDecoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: isDarkMode ? Colors.pink.shade700 : Colors.blue,
                  shape: BoxShape.circle,
                ),
                // Text colors for dark mode
                defaultTextStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                weekendTextStyle: TextStyle(
                  color: isDarkMode ? Colors.red.shade200 : Colors.red,
                ),
                outsideTextStyle: TextStyle(
                  color:
                      isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                  fontSize: 17.0,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                formatButtonTextStyle: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.blue,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
                weekendStyle: TextStyle(
                  color: isDarkMode ? Colors.red.shade200 : Colors.red,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final widgets = <Widget>[];

                  // Add period marker
                  if (periodProvider.isPeriodDay(date)) {
                    widgets.add(
                      const Positioned(
                        bottom: 1,
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.red,
                        ),
                      ),
                    );
                  }

                  // Add ovulation marker
                  if (periodProvider.isOvulationDay(date)) {
                    widgets.add(
                      const Positioned(
                        bottom: 1,
                        right: 1,
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.green,
                        ),
                      ),
                    );
                  }

                  // Add fertile window marker
                  if (periodProvider.isFertileDay(date) &&
                      !periodProvider.isOvulationDay(date)) {
                    widgets.add(
                      const Positioned(
                        bottom: 1,
                        left: 1,
                        child: CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.lightGreen,
                        ),
                      ),
                    );
                  }

                  // Upcoming period prediction
                  if (periodProvider.currentPeriod != null) {
                    final nextPeriodStart =
                        periodProvider.currentPeriod!.nextPeriodStart;
                    final periodEndDay = nextPeriodStart.add(
                      Duration(
                        days: periodProvider.currentPeriod!.periodLength - 1,
                      ),
                    );

                    if (custom_utils.PeriodDateUtils.isDayInRange(
                      date,
                      nextPeriodStart,
                      periodEndDay,
                    )) {
                      widgets.add(
                        Positioned(
                          top: 1,
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: Colors.red.withOpacity(0.5),
                          ),
                        ),
                      );
                    }
                  }

                  return Stack(children: widgets);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
