import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/child_selector.dart';
import '../../provider/student_fee_provider.dart';
import '../../provider/parent_child_provider.dart';

class FeeScreen extends StatefulWidget {
  const FeeScreen({super.key});

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  int? _selectedChildId;
  int? _selectedSemesterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childProvider = context.read<ParentChildProvider>();
      if (childProvider.children.isNotEmpty && _selectedChildId == null) {
        _selectedChildId = childProvider.children.first.studentId;
        _fetchFees();
      }
    });
  }

  void _fetchFees() {
    if (_selectedChildId == null) return;
    
    final provider = context.read<StudentFeeProvider>();
    if (_selectedSemesterId != null) {
      provider.fetchFeesBySemester(_selectedChildId!, _selectedSemesterId!);
    } else {
      provider.fetchStudentFees(_selectedChildId!);
      provider.fetchTotalUnpaidAmount(_selectedChildId!);
    }
  }

  void _onChildSelected(int childId) {
    setState(() => _selectedChildId = childId);
    _fetchFees();
  }

  Widget _buildStatusBadge(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
        return StatusBadge.paid();
      case 'UNPAID':
        return StatusBadge.unpaid();
      case 'OVERDUE':
        return StatusBadge.overdue();
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(status, style: AppTextStyles.caption),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ParentChildProvider>();
    final feeProvider = context.watch<StudentFeeProvider>();

    if (childProvider.children.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Học phí', style: AppTextStyles.h2),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Chưa có dữ liệu học sinh'),
        ),
      );
    }

    _selectedChildId ??= childProvider.children.first.studentId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Học phí', style: AppTextStyles.h2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (childProvider.children.length > 1)
            ChildSelector(
              children: childProvider.children
                  .map((c) => ChildData(studentId: c.studentId, name: c.fullName))
                  .toList(),
              selectedId: _selectedChildId!,
              onSelected: _onChildSelected,
            ),
          
          const SizedBox(height: 12),
          
          // Semester Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Học kỳ:', style: AppTextStyles.body),
                  DropdownButton<int?>(
                    value: _selectedSemesterId,
                    onChanged: (value) {
                      setState(() => _selectedSemesterId = value);
                      _fetchFees();
                    },
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      const DropdownMenuItem(
                        value: 1,
                        child: Text('Học kỳ 1'),
                      ),
                      const DropdownMenuItem(
                        value: 2,
                        child: Text('Học kỳ 2'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),

          if (feeProvider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (feeProvider.error != null)
            Expanded(
              child: Center(
                child: Text(
                  feeProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            )
          else if (feeProvider.feesList.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Không có dữ liệu học phí',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Summary Card
                  AppCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text('Tổng học phí', style: AppTextStyles.body),
                            const Spacer(),
                            Text(
                              feeProvider.feesList
                                  .fold(0.0, (sum, fee) => sum + fee.amount)
                                  .toStringAsFixed(0),
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Đã thanh toán', style: AppTextStyles.body),
                            const Spacer(),
                            Text(
                              feeProvider.feesList
                                  .fold(0.0, (sum, fee) => sum + fee.paidAmount)
                                  .toStringAsFixed(0),
                              style: AppTextStyles.h3.copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: AppColors.divider),
                        ),
                        Row(
                          children: [
                            Text(
                              'Còn lại',
                              style: AppTextStyles.subtitle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              (feeProvider.totalUnpaidAmount ?? 0).toStringAsFixed(0),
                              style: AppTextStyles.h2.copyWith(color: AppColors.error),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Fees List
                  ...feeProvider.feesList.map((fee) {
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
                                    fee.feeTypeName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Hạn: ${fee.dueDate}',
                                    style: AppTextStyles.caption,
                                  ),
                                  if (fee.semesterName.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      fee.semesterName,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  fee.amount.toStringAsFixed(0),
                                  style: AppTextStyles.h3,
                                ),
                                const SizedBox(height: 4),
                                _buildStatusBadge(fee.status),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đây là thông tin theo dõi học phí từ hệ thống.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
