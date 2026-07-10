import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_shadows.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/child_selector.dart';

class FeeScreen extends StatefulWidget {
  const FeeScreen({super.key});

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  int _selectedChildId = 1;

  final List<ChildData> _children = const [
    ChildData(studentId: 1, name: 'Nguyễn Văn B'),
    ChildData(studentId: 2, name: 'Nguyễn Thị C'),
  ];

  @override
  Widget build(BuildContext context) {
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
          if (_children.length > 1)
            ChildSelector(
              children: _children,
              selectedId: _selectedChildId,
              onSelected: (id) => setState(() => _selectedChildId = id),
            ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 24),
                
                const Text('Học kỳ Fall 2026', style: AppTextStyles.subtitle),
                const SizedBox(height: 12),
                
                _buildFeeItem('Học phí tín chỉ', '12,000,000 đ', '15/08/2026', StatusBadge.partiallyPaid()),
                _buildFeeItem('Phí BHYT', '800,000 đ', '15/08/2026', StatusBadge.unpaid()),
                _buildFeeItem('Phí hoạt động', '500,000 đ', '01/07/2026', StatusBadge.overdue()),
                _buildFeeItem('Phí ký túc xá', '1,700,000 đ', '01/06/2026', StatusBadge.paid()),
                
                const SizedBox(height: 32),
                
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
                          'Đây là thông tin theo dõi học phí, không hỗ trợ thanh toán trực tuyến trong phạm vi hiện tại.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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

  Widget _buildSummaryCard() {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text('Tổng học phí', style: AppTextStyles.body),
              const Spacer(),
              const Text('15,000,000 đ', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Đã thanh toán', style: AppTextStyles.body),
              const Spacer(),
              Text('9,800,000 đ', style: AppTextStyles.h3.copyWith(color: AppColors.success)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          Row(
            children: [
              Text('Còn lại', style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('5,200,000 đ', style: AppTextStyles.h2.copyWith(color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Hạn thanh toán tiếp theo', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              Text('15/08/2026', style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(String title, String amount, String dueDate, Widget status) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Hạn: $dueDate', style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: AppTextStyles.h3),
              const SizedBox(height: 4),
              status,
            ],
          ),
        ],
      ),
    );
  }
}
