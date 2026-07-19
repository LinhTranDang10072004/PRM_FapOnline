import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/parent_child_provider.dart';
import '../../models/response/weekly_timetable_dto.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/app_card.dart';
import '../../widgets/child_selector.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_skeleton.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _selectedFilter = 'all'; // 'all', 'present', 'absent', 'not_yet'
  late DateTime _startDate;
  late DateTime _endDate;
  int? _loadedChildId;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _getMonday(_endDate);
    _endDate = _startDate.add(const Duration(days: 6));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ParentChildProvider>();
    final childId = provider.selectedChildId;

    // selectedChildId is set after children are fetched. Wait for that value
    // instead of completing initialization while it is still null.
    if (childId != null && _loadedChildId != childId) {
      _loadedChildId = childId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchTimetable();
      });
    }
  }

  void _fetchTimetable() {
    final provider = context.read<ParentChildProvider>();
    final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate);
    provider.fetchTimetable(startDate: startDateStr, endDate: endDateStr);
  }

  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ParentChildProvider>();
    final childrenData = provider.children
        .map((e) => ChildData(studentId: e.studentId, name: e.fullName))
        .toList();

    // Ensure the default child filter also triggers a load on a rebuild.
    final childId = provider.selectedChildId;
    if (childId != null && _loadedChildId != childId) {
      _loadedChildId = childId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchTimetable();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thời khóa biểu', style: AppTextStyles.h2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                        initialDate: _startDate.isBefore(DateTime.now())
                            ? _startDate
                            : DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: _endDate.isBefore(DateTime.now())
                            ? _endDate
                            : DateTime.now(),
                      );
                      if (picked != null && picked != _startDate) {
                        setState(() => _startDate = picked);
                        _fetchTimetable();
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
                        initialDate: _endDate.isAfter(DateTime.now())
                            ? DateTime.now()
                            : _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _endDate) {
                        setState(() => _endDate = picked);
                        _fetchTimetable();
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

          if (childrenData.length > 1) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.subtle,
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value:
                        provider.selectedChildId ??
                        (childrenData.isNotEmpty
                            ? childrenData.first.studentId
                            : null),
                    icon: const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                    items: childrenData.map((child) {
                      return DropdownMenuItem<int>(
                        value: child.studentId,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primaryLight
                                  .withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(child.name, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        provider.selectChild(value);
                        _fetchTimetable();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Tất cả', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Chưa học', 'not_yet'),
                const SizedBox(width: 8),
                _buildFilterChip('Có mặt', 'present'),
                const SizedBox(width: 8),
                _buildFilterChip('Vắng mặt', 'absent'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: provider.isLoadingTimetable
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: _buildTimetableData(provider.currentTimetable),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _formatDayHeader(int dayOffset) {
    final date = _startDate.add(Duration(days: dayOffset));
    final weekdays = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    return '${weekdays[date.weekday - 1]}, ${_formatDate(date)}/${date.year}';
  }

  List<Widget> _buildTimetableData(List<WeeklyTimetableDTO> schedules) {
    if (schedules.isEmpty) {
      return [
        const SizedBox(height: 100),
        const Center(
          child: Text(
            'Không có dữ liệu thời khóa biểu cho tuần này',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ];
    }

    // Group by date
    final grouped = <String, List<WeeklyTimetableDTO>>{};
    for (var s in schedules) {
      final dateStr = s.scheduleDate.toString();
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(s);
    }

    // Sort dates
    final dates = grouped.keys.toList()..sort();

    List<Widget> items = [];
    for (var date in dates) {
      final dailySchedules = grouped[date]!;

      // Filter schedules
      final filtered = dailySchedules.where((s) {
        if (_selectedFilter == 'all') return true;
        if (_selectedFilter == 'present' && s.status == 'PRESENT') return true;
        if (_selectedFilter == 'absent' && s.status == 'ABSENT') return true;
        if (_selectedFilter == 'not_yet' && s.status == 'NOT_YET') return true;
        return false;
      }).toList();

      if (filtered.isNotEmpty) {
        // Parse date for header
        DateTime d;
        try {
          d = DateTime.parse(date);
        } catch (_) {
          d = DateTime.now();
        }

        final weekdays = [
          'Thứ Hai',
          'Thứ Ba',
          'Thứ Tư',
          'Thứ Năm',
          'Thứ Sáu',
          'Thứ Bảy',
          'Chủ Nhật',
        ];
        final dayStr =
            '${weekdays[d.weekday - 1]}, ${_formatDate(d)}/${d.year}';
        items.add(_buildDayHeader(dayStr));

        for (var s in filtered) {
          // Parse time safely
          String startTimeStr = '??:??';
          String endTimeStr = '??:??';

          try {
            if (s.startTime != null) {
              startTimeStr = s.startTime.toString().substring(0, 5);
            }
            if (s.endTime != null) {
              endTimeStr = s.endTime.toString().substring(0, 5);
            }
          } catch (e) {
            print('Error parsing time: $e');
          }

          final timeStr = '$startTimeStr - $endTimeStr';
          final statusStr =
              s.status?.toLowerCase() ??
              'not_yet'; // 'present', 'absent', 'not_yet'
          items.add(
            _buildSessionCard(
              s.subjectCode,
              timeStr,
              s.roomName,
              'Lecturer',
              'Class',
              statusStr,
            ),
          );
        }
      } else if (_selectedFilter == 'all') {
        DateTime d;
        try {
          d = DateTime.parse(date);
        } catch (_) {
          d = DateTime.now();
        }
        final weekdays = [
          'Thứ Hai',
          'Thứ Ba',
          'Thứ Tư',
          'Thứ Năm',
          'Thứ Sáu',
          'Thứ Bảy',
          'Chủ Nhật',
        ];
        final dayStr =
            '${weekdays[d.weekday - 1]}, ${_formatDate(d)}/${d.year}';
        items.add(_buildDayHeader(dayStr));
        items.add(_buildEmptyDay());
      }
    }

    items.add(const SizedBox(height: 24));
    return items;
  }

  Widget _buildDayHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        if (selected) setState(() => _selectedFilter = value);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: _selectedFilter == value
            ? Colors.white
            : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status) {
      case 'present':
        return StatusBadge.present();
      case 'absent':
        return StatusBadge.absent();
      case 'not_yet':
        return StatusBadge(
          label: 'Chưa học',
          backgroundColor: AppColors.primaryLight.withOpacity(0.12),
          textColor: AppColors.primaryLight,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSessionCard(
    String subject,
    String time,
    String room,
    String teacher,
    String className,
    String status,
  ) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        time,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.room_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(room, style: AppTextStyles.caption),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(teacher, style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lớp: $className',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Không có lịch học',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.textHint,
          ),
        ),
      ),
    );
  }
}
