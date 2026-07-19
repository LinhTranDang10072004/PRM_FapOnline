import 'timetable_model.dart';

class TimeSlotSummaryModel {
  final String slotCode;
  final String slotTime;

  TimeSlotSummaryModel({
    required this.slotCode,
    required this.slotTime,
  });

  factory TimeSlotSummaryModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotSummaryModel(
      slotCode: json['slotCode'] ?? '',
      slotTime: json['slotTime'] ?? '',
    );
  }
}

class DayColumnModel {
  final String date;
  final String dayLabel;
  final String dateLabel;

  DayColumnModel({
    required this.date,
    required this.dayLabel,
    required this.dateLabel,
  });

  factory DayColumnModel.fromJson(Map<String, dynamic> json) {
    return DayColumnModel(
      date: json['date']?.toString() ?? '',
      dayLabel: json['dayLabel'] ?? '',
      dateLabel: json['dateLabel'] ?? '',
    );
  }
}

class WeeklyTimetableModel {
  final int year;
  final String weekStart;
  final String weekEnd;
  final String weekLabel;
  final List<TimeSlotSummaryModel> slots;
  final List<DayColumnModel> days;
  final List<TimetableModel> entries;

  WeeklyTimetableModel({
    required this.year,
    required this.weekStart,
    required this.weekEnd,
    required this.weekLabel,
    required this.slots,
    required this.days,
    required this.entries,
  });

  factory WeeklyTimetableModel.fromJson(Map<String, dynamic> json) {
    return WeeklyTimetableModel(
      year: json['year'] ?? DateTime.now().year,
      weekStart: json['weekStart']?.toString() ?? '',
      weekEnd: json['weekEnd']?.toString() ?? '',
      weekLabel: json['weekLabel'] ?? '',
      slots: (json['slots'] as List<dynamic>?)
              ?.map((e) => TimeSlotSummaryModel.fromJson(e))
              .toList() ??
          [],
      days: (json['days'] as List<dynamic>?)
              ?.map((e) => DayColumnModel.fromJson(e))
              .toList() ??
          [],
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => TimetableModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  TimetableModel? entryFor(String slotCode, String date) {
    final matches = entries.where(
      (entry) => entry.slotCode == slotCode && entry.scheduleDate == date,
    );
    return matches.isEmpty ? null : matches.first;
  }
}
