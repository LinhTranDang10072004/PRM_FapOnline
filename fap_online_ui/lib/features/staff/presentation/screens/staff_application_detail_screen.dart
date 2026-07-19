import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_colors.dart';
import '../providers/staff_application_provider.dart';
import '../../data/models/staff_models.dart';

class StaffApplicationDetailScreen extends StatelessWidget {
  final ApplicationModel application;

  const StaffApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final isPending = application.status == 'Pending';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Chi tiết đơn từ',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner
          _StatusBanner(status: application.status ?? ''),
          const SizedBox(height: 16),

          // Student info
          _SectionCard(
            title: 'Thông tin sinh viên',
            icon: Icons.person_rounded,
            children: [
              _Row('Tên SV', application.studentName),
              _Row('Mã SV', application.studentCode),
            ],
          ),
          const SizedBox(height: 12),

          // Application info
          _SectionCard(
            title: 'Thông tin đơn',
            icon: Icons.description_rounded,
            children: [
              _Row('Loại đơn', application.applicationTypeName),
              _Row('Tiêu đề', application.title),
              if (application.startDate != null)
                _Row('Từ ngày', application.startDate),
              if (application.endDate != null)
                _Row('Đến ngày', application.endDate),
              _Row('Ngày gửi', application.displayCreatedAt),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          if ((application.content?.isNotEmpty ?? false))
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.article_rounded,
                          size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Nội dung đơn',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    application.content!,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.6,
                        fontSize: 14),
                  ),
                ],
              ),
            ),

          // Process info (if already processed)
          if (!isPending && application.processedByName != null) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Kết quả xử lý',
              icon: Icons.check_circle_outline_rounded,
              children: [
                _Row('Người xử lý', application.processedByName),
                if (application.processNote?.isNotEmpty == true)
                  _Row('Ghi chú', application.processNote),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons (only for Pending)
          if (isPending) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Từ chối'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _showApproveDialog(context),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Duyệt'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  void _showApproveDialog(BuildContext context) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('Duyệt đơn', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: TextField(
          controller: noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Ghi chú (tùy chọn)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              final provider = context.read<StaffApplicationProvider>();
              final err = await provider.approveApplication(
                application.applicationId!,
                note: noteCtrl.text.trim().isNotEmpty
                    ? noteCtrl.text.trim()
                    : null,
              );
              if (!context.mounted) return;
              Navigator.pop(context); // close dialog
              if (err == null) {
                Navigator.pop(context); // back to list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã duyệt đơn thành công!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(err),
                  backgroundColor: AppColors.error,
                ));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Xác nhận duyệt'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Từ chối đơn',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: noteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Lý do từ chối *',
              hintText: 'Bắt buộc nhập lý do...',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập lý do' : null,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final provider = context.read<StaffApplicationProvider>();
              final err = await provider.rejectApplication(
                application.applicationId!,
                note: noteCtrl.text.trim(),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              if (err == null) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã từ chối đơn.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(err),
                  backgroundColor: AppColors.error,
                ));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xác nhận từ chối'),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        bg = AppColors.warningLight;
        fg = const Color(0xFFB45309);
        icon = Icons.pending_actions_rounded;
        break;
      case 'approved':
        bg = AppColors.successLight;
        fg = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        bg = AppColors.errorLight;
        fg = AppColors.error;
        icon = Icons.cancel_rounded;
        break;
      default:
        bg = AppColors.background;
        fg = AppColors.textSecondary;
        icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 10),
          Text(
            'Trạng thái: $status',
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_Row> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '—',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
