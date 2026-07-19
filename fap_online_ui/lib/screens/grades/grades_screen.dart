import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/child_selector.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int _selectedChildId = 1;

  final List<ChildData> _children = const [
    ChildData(studentId: 1, name: 'Nguyễn Văn B'),
    ChildData(studentId: 2, name: 'Nguyễn Thị C'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Bảng điểm', style: AppTextStyles.h2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.divider.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Điểm theo môn'),
                    Tab(text: 'Bảng điểm tổng hợp'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            if (_children.length > 1)
              ChildSelector(
                children: _children,
                selectedId: _selectedChildId,
                onSelected: (id) => setState(() => _selectedChildId = id),
              ),
            
            Expanded(
              child: TabBarView(
                children: [
                  _buildCurrentSemesterGrades(),
                  _buildAllSemestersGrades(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSemesterGrades() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _buildSubjectExpandableCard(
          'PRM301 - Mobile Programming', 8.2, true,
          {'Điểm chuyên cần': '9.0', 'Bài tập': '8.0', 'Giữa kỳ': '7.5', 'Cuối kỳ': '8.5'},
        ),
        _buildSubjectExpandableCard(
          'SWP391 - Software Project', 7.1, true,
          {'Điểm chuyên cần': '8.5', 'Bài tập': '7.0', 'Giữa kỳ': '6.5', 'Cuối kỳ': '7.0'},
        ),
        _buildSubjectExpandableCard(
          'JPD113 - Japanese 1', 8.7, true,
          {'Điểm chuyên cần': '10.0', 'Bài tập': '9.0', 'Giữa kỳ': '8.0', 'Cuối kỳ': '8.5'},
        ),
        _buildSubjectExpandableCard(
          'PRN211 - .NET Programming', 4.2, false,
          {'Điểm chuyên cần': '7.0', 'Bài tập': '5.0', 'Giữa kỳ': '4.0', 'Cuối kỳ': '3.5'},
        ),
      ],
    );
  }

  Widget _buildSubjectExpandableCard(String title, double totalGrade, bool isPass, Map<String, String> components) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              totalGrade.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: totalGrade >= 5 ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ...components.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Text(e.key, style: AppTextStyles.body),
                      const Spacer(),
                      Text(e.value, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                )),
                const Divider(height: 16, color: AppColors.divider),
                Row(
                  children: [
                    const Text('Điểm tổng kết', style: AppTextStyles.subtitle),
                    const Spacer(),
                    Text(
                      totalGrade.toString(),
                      style: AppTextStyles.h3.copyWith(
                        color: totalGrade >= 5 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Trạng thái', style: AppTextStyles.subtitle),
                    const Spacer(),
                    isPass ? const StatusBadge(label: 'Đạt', backgroundColor: AppColors.successLight, textColor: AppColors.success)
                           : const StatusBadge(label: 'Không đạt', backgroundColor: AppColors.errorLight, textColor: AppColors.error),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSemestersGrades() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('GPA Tích lũy', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text('7.8', style: AppTextStyles.h1.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ),
                Container(width: 1, height: 60, color: AppColors.divider),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Tín chỉ tích lũy', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text('95/150', style: AppTextStyles.h2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            padding: const EdgeInsets.all(0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow(['Mã môn', 'TC', 'Điểm', 'KQ'], isHeader: true),
                _buildTableRow(['PRM301', '3', '8.2', 'Đạt']),
                _buildTableRow(['SWP391', '3', '7.1', 'Đạt']),
                _buildTableRow(['JPD113', '3', '8.7', 'Đạt']),
                _buildTableRow(['PRN211', '3', '4.2', 'Trượt'], isFail: true),
                _buildTableRow(['ITE302', '3', '7.5', 'Đạt']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false, bool isFail = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? AppColors.shimmerHighlight : Colors.transparent,
        border: const Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      children: cells.map((cell) {
        final isStatus = cell == 'Đạt' || cell == 'Trượt';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: isStatus
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(
                    label: cell,
                    backgroundColor: isFail ? AppColors.errorLight : AppColors.successLight,
                    textColor: isFail ? AppColors.error : AppColors.success,
                  ),
                )
              : Text(
                  cell,
                  style: isHeader
                      ? AppTextStyles.captionBold.copyWith(color: AppColors.textPrimary)
                      : AppTextStyles.bodyMedium.copyWith(color: isFail ? AppColors.error : AppColors.textPrimary),
                ),
        );
      }).toList(),
    );
  }
}
