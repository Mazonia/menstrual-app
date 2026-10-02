class Period {
  final DateTime startDate;
  final int cycleLength;
  final int periodLength;

  Period({
    required this.startDate,
    this.cycleLength = 28,
    this.periodLength = 5,
  });

  DateTime get endDate => startDate.add(Duration(days: periodLength - 1));

  DateTime get nextPeriodStart => startDate.add(Duration(days: cycleLength));

  DateTime get ovulationDate => startDate.add(Duration(days: cycleLength - 14));

  List<DateTime> get fertileWindow {
    final List<DateTime> window = [];
    final DateTime start = ovulationDate.subtract(const Duration(days: 5));

    for (var i = 0; i < 11; i++) {
      window.add(start.add(Duration(days: i)));
    }

    return window;
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
    };
  }

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      startDate: DateTime.parse(json['startDate']),
      cycleLength: json['cycleLength'],
      periodLength: json['periodLength'],
    );
  }
}
