import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../services/auth_service.dart';
import '../../models/weekly_timetable_model.dart';
import '../../models/timetable_model.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final StudentApiService _studentApiService = StudentApiService();
  final AuthService _authService = AuthService();

  late DateTime _weekStart;
  Future<WeeklyTimetableModel>? _timetableFuture;

  @override
  void initState() {
    super.initState();
    _weekStart = _startOfWeek(DateTime.now());
    _loadTimetable();
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - DateTime.monday));
  }

  void _loadTimetable() {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    setState(() {
      _timetableFuture = _fetchTimetable(_weekStart, weekEnd);
    });
  }

  Future<WeeklyTimetableModel> _fetchTimetable(DateTime from, DateTime to) async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token đăng nhập. Vui lòng đăng nhập lại.');
    }
    return _studentApiService.getWeeklyTimetable(token, fromDate: from, toDate: to);
  }

  void _changeWeek(int direction) {
    _weekStart = _weekStart.add(Duration(days: 7 * direction));
    _loadTimetable();
  }

  String _formatWeekLabel(DateTime start) {
    final end = start.add(const Duration(days: 6));
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(start.day)}/${two(start.month)} To ${two(end.day)}/${two(end.month)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Weekly Timetable'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTimetable,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: FutureBuilder<WeeklyTimetableModel>(
              future: _timetableFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('Không có dữ liệu thời khóa biểu.'));
                }

                return _buildTimetableGrid(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          _toolbarChip('Year', '${_weekStart.year}'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeWeek(-1),
              ),
              _toolbarChip('Week', _formatWeekLabel(_weekStart)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeWeek(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toolbarChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 18),
        ],
      ),
    );
  }

  Widget _buildTimetableGrid(WeeklyTimetableModel timetable) {
    final slots = timetable.slots;
    final days = timetable.days;

    if (slots.isEmpty || days.isEmpty) {
      return const Center(child: Text('Chưa có cấu hình slot hoặc lịch trong tuần này.'));
    }

    const slotColumnWidth = 90.0;
    const dayColumnWidth = 150.0;
    const rowHeight = 130.0;
    const headerHeight = 56.0;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _headerCell('', slotColumnWidth, headerHeight, isCorner: true),
                ...days.map(
                  (day) => _headerCell(
                    '${day.dayLabel}\n${day.dateLabel}',
                    dayColumnWidth,
                    headerHeight,
                  ),
                ),
              ],
            ),
            ...slots.map((slot) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _slotHeaderCell(slot.slotCode, slotColumnWidth, rowHeight),
                  ...days.map((day) {
                    final entry = timetable.entryFor(slot.slotCode, day.date);
                    return _scheduleCell(entry, dayColumnWidth, rowHeight);
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, double width, double height, {bool isCorner = false}) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCorner ? const Color(0xFFECEFF1) : const Color(0xFFCFD8DC),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _slotHeaderCell(String slotCode, double width, double height) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: Text(
        slotCode,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _scheduleCell(TimetableModel? entry, double width, double height) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
      ),
      child: entry == null ? _emptyCell() : _filledCell(entry),
    );
  }

  Widget _emptyCell() {
    return const Center(
      child: Text('-', style: TextStyle(color: Colors.grey, fontSize: 18)),
    );
  }

  Widget _filledCell(TimetableModel entry) {
    final statusLabel = entry.statusLabel ?? entry.attendanceLabel;
    final statusType = entry.statusType ?? '';
    final statusColor = _statusColor(statusType);
    final timeBorderColor = _timeBorderColor(statusType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.subjectCode ?? '',
          style: const TextStyle(
            color: Color(0xFF1565C0),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'at ${entry.roomCode ?? ''}',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
        if (statusLabel != null && statusLabel.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '($statusLabel)',
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const Spacer(),
        if (entry.slotTime != null && entry.slotTime!.isNotEmpty)
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: timeBorderColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                entry.slotTime!,
                style: TextStyle(
                  color: timeBorderColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _statusColor(String statusType) {
    switch (statusType) {
      case 'present':
        return Colors.green.shade700;
      case 'absent':
        return Colors.red.shade700;
      case 'not_yet':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _timeBorderColor(String statusType) {
    switch (statusType) {
      case 'present':
        return Colors.green.shade700;
      case 'absent':
        return Colors.red.shade400;
      case 'not_yet':
        return Colors.blue.shade400;
      default:
        return Colors.grey.shade500;
    }
  }
}
