import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/child_selector.dart';
import '../../provider/attendance_provider.dart';
import '../../provider/parent_child_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  int? _selectedChildId;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Children are loaded asynchronously. Initialise this filter as soon as
    // they become available, then load the data without requiring a tap.
    final children = context.read<ParentChildProvider>().children;
    if (_selectedChildId == null && children.isNotEmpty) {
      _selectedChildId = children.first.studentId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchAttendance();
      });
    }
  }

  void _fetchAttendance() {
    if (_selectedChildId == null) return;

    final provider = context.read<AttendanceProvider>();
    provider.fetchStudentAttendance(
      _selectedChildId!,
      _startDate.toString().split(' ')[0],
      _endDate.toString().split(' ')[0],
    );
  }

  void _onChildSelected(int childId) {
    setState(() => _selectedChildId = childId);
    _fetchAttendance();
  }

  void _onDateRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _fetchAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ParentChildProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    if (childProvider.children.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Báo cáo điểm danh', style: AppTextStyles.h2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(child: Text('Chưa có dữ liệu học sinh')),
      );
    }

    // Fallback for a provider update that rebuilds this screen without
    // invoking didChangeDependencies.
    if (_selectedChildId == null) {
      _selectedChildId = childProvider.children.first.studentId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchAttendance();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Báo cáo điểm danh', style: AppTextStyles.h2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (childProvider.children.length > 1)
            ChildSelector(
              children: childProvider.children
                  .map(
                    (c) => ChildData(studentId: c.studentId, name: c.fullName),
                  )
                  .toList(),
              selectedId: _selectedChildId!,
              onSelected: _onChildSelected,
            ),

          const SizedBox(height: 12),

          // Date Range Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: _endDate,
                      );
                      if (picked != null && picked != _startDate) {
                        setState(() => _startDate = picked);
                        _fetchAttendance();
                      }
                    },
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Từ ngày',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _startDate.toString().split(' ')[0],
                                  style: AppTextStyles.subtitle,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _endDate) {
                        setState(() => _endDate = picked);
                        _fetchAttendance();
                      }
                    },
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Đến ngày',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _endDate.toString().split(' ')[0],
                                  style: AppTextStyles.subtitle,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (attendanceProvider.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (attendanceProvider.error != null)
            Expanded(
              child: Center(
                child: Text(
                  attendanceProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            )
          else if (attendanceProvider.attendanceList.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Không có dữ liệu điểm danh',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: attendanceProvider.attendanceList.length,
                itemBuilder: (context, index) {
                  final attendance = attendanceProvider.attendanceList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attendance.subjectCode,
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  attendance.date,
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  attendance.timeSlot,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(attendance.status),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status.toUpperCase()) {
      case 'PRESENT':
        return StatusBadge.present();
      case 'ABSENT':
        return StatusBadge.absent();
      case 'LATE':
        return StatusBadge.late();
      case 'EXCUSED':
        return StatusBadge.excused();
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(status, style: AppTextStyles.caption),
        );
    }
  }
}
