import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/child_selector.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int _selectedChildId = 1;
  String _selectedFilter = 'Tất cả môn';

  final List<ChildData> _children = const [
    ChildData(studentId: 1, name: 'Nguyễn Văn B'),
    ChildData(studentId: 2, name: 'Nguyễn Thị C'),
  ];
  
  final List<String> _filters = ['Tất cả môn', 'PRM301', 'SWP391', 'JPD113'];

  @override
  Widget build(BuildContext context) {
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
          if (_children.length > 1)
            ChildSelector(
              children: _children,
              selectedId: _selectedChildId,
              onSelected: (id) => setState(() => _selectedChildId = id),
            ),
          
          const SizedBox(height: 12),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ..._filters.map((filter) {
                  final isSelected = filter == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      onSelected: (selected) => setState(() => _selectedFilter = filter),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Chip(
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Fall 2026'),
                      Icon(Icons.arrow_drop_down, size: 18),
                    ],
                  ),
                  backgroundColor: AppColors.primaryLight.withOpacity(0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('45', 'Có mặt', AppColors.success),
                      Container(height: 40, width: 1, color: AppColors.divider),
                      _buildStatItem('3', 'Vắng CP', AppColors.warning),
                      Container(height: 40, width: 1, color: AppColors.divider),
                      _buildStatItem('1', 'Vắng KP', AppColors.error),
                      Container(height: 40, width: 1, color: AppColors.divider),
                      _buildStatItem('2', 'Muộn', AppColors.accent),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 45 / 51,
                      minHeight: 8,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('88% tỷ lệ điểm danh', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSubjectGroup('PRM301 - Mobile Programming', [
                  _SessionData('28/06', 'Slot 1 (07:30)', const StatusBadge.present()),
                  _SessionData('30/06', 'Slot 1 (07:30)', const StatusBadge.late()),
                  _SessionData('05/07', 'Slot 1 (07:30)', const StatusBadge.absent()),
                  _SessionData('07/07', 'Slot 1 (07:30)', const StatusBadge.present()),
                ]),
                const SizedBox(height: 16),
                _buildSubjectGroup('SWP391 - Software Project', [
                  _SessionData('28/06', 'Slot 2 (09:30)', const StatusBadge.present()),
                  _SessionData('02/07', 'Slot 2 (09:30)', const StatusBadge.excused()),
                  _SessionData('05/07', 'Slot 2 (09:30)', const StatusBadge.present()),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(number, style: AppTextStyles.h2.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildSubjectGroup(String title, List<_SessionData> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sessions.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(session.date, style: AppTextStyles.caption),
                    const SizedBox(width: 16),
                    Text(session.time, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)),
                    const Spacer(),
                    session.statusBadge,
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SessionData {
  final String date;
  final String time;
  final Widget statusBadge;
  _SessionData(this.date, this.time, this.statusBadge);
}
